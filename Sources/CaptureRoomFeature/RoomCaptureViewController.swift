//
//  RoomCaptureViewController.swift
//  Menata
//
//  Created by Muhamad Azis on 24/06/25.
//

import UIKit
import RoomPlan
import os

class RoomCaptureViewController: UIViewController, RoomCaptureViewDelegate, RoomCaptureSessionDelegate {
    private var roomCaptureView: RoomCaptureView!
    private var roomCaptureSessionConfig = RoomCaptureSession.Configuration()
    private var finalResults: CapturedRoom?
    private let logger = Logger(subsystem: "MenataApp", category: "RoomCapture")

    var dismissHandler: (() -> Void)?
    private var exportButton: UIButton!
    private var backButton: UIButton!
    
    // Room folder structure
    private let roomFolder: RoomFolder = RoomFolder()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupRoomCaptureView()
        startSession()
        view.backgroundColor = .black

        setupNavigationBar()
        setupExportButton()
        setupBackButton()
    }

    private func setupRoomCaptureView() {
        roomCaptureView = RoomCaptureView(frame: .zero)
        roomCaptureView.captureSession.delegate = self
        roomCaptureView.delegate = self
        roomCaptureView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(roomCaptureView, at: 0)

        NSLayoutConstraint.activate([
            roomCaptureView.topAnchor.constraint(equalTo: view.topAnchor),
            roomCaptureView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            roomCaptureView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            roomCaptureView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutIfNeeded()
    }

    private func startSession() {
        roomCaptureView.captureSession.run(configuration: roomCaptureSessionConfig)
    }

    private func stopSession() {
        roomCaptureView.captureSession.stop()
    }

    private func setupNavigationBar() {
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelScanning))
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneScanning))
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = doneButton
        navigationController?.navigationBar.tintColor = .white
    }

    private func setupExportButton() {
        exportButton = UIButton(type: .system)
        exportButton.setTitle("Export", for: .normal)
        exportButton.tintColor = .white
        exportButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.8)
        exportButton.layer.cornerRadius = 10
        exportButton.translatesAutoresizingMaskIntoConstraints = false
        exportButton.addTarget(self, action: #selector(exportResults), for: .touchUpInside)
        exportButton.isHidden = true

        view.addSubview(exportButton)
        NSLayoutConstraint.activate([
            exportButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            exportButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            exportButton.widthAnchor.constraint(equalToConstant: 120),
            exportButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func setupBackButton() {
        backButton = UIButton(type: .system)
        backButton.setTitle("Back", for: .normal)
        backButton.tintColor = .white
        backButton.backgroundColor = UIColor.systemGray.withAlphaComponent(0.8)
        backButton.layer.cornerRadius = 10
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        backButton.isHidden = true

        view.addSubview(backButton)
        NSLayoutConstraint.activate([
            backButton.bottomAnchor.constraint(equalTo: exportButton.topAnchor, constant: -12),
            backButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 120),
            backButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    @objc private func cancelScanning() {
        stopSession()
        dismissHandler?()
    }

    @objc private func doneScanning() {
        stopSession()
        exportButton.isHidden = false
        backButton.isHidden = false
    }

    @objc private func goBack() {
        dismissHandler?()
    }

    func captureView(shouldPresent roomDataForProcessing: CapturedRoomData, error: Error?) -> Bool {
        return true
    }

    func captureView(didPresent processedResult: CapturedRoom, error: Error?) {
        finalResults = processedResult
    }

    @objc private func exportResults() {
        guard let finalResults else {
            logger.error("No final results to export")
            return
        }

        do {
            // Generate unique filename with timestamp
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
            let timestamp = dateFormatter.string(from: Date())
            let roomName = "Room_\(timestamp)"
            
            // Export USDZ model to Models folder
            let usdzURL = roomFolder.modelsFolder.appendingPathComponent("\(roomName).usdz")
            try finalResults.export(to: usdzURL, exportOptions: .parametric)
            logger.log("Successfully exported USDZ to: \(usdzURL.path)")

            // Export JSON data to Models folder
            let jsonURL = roomFolder.modelsFolder.appendingPathComponent("\(roomName).json")
            let jsonData = try JSONEncoder().encode(finalResults)
            try jsonData.write(to: jsonURL)
            logger.log("Successfully exported JSON to: \(jsonURL.path)")
            
            // Show success alert
            showSuccessAlert(roomName: roomName, usdzPath: usdzURL.path, jsonPath: jsonURL.path)
            
        } catch {
            logger.error("Export failed: \(error.localizedDescription)")
            showErrorAlert(error: error)
        }
    }
    
    private func showSuccessAlert(roomName: String, usdzPath: String, jsonPath: String) {
        let alert = UIAlertController(
            title: "Export Successful",
            message: "Room '\(roomName)' has been saved to Menata/Rooms/Models/",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Share", style: .default) { [weak self] _ in
            self?.shareFiles(usdzPath: usdzPath, jsonPath: jsonPath)
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.dismissHandler?()
        })
        
        present(alert, animated: true)
    }
    
    private func showErrorAlert(error: Error) {
        let alert = UIAlertController(
            title: "Export Failed",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func shareFiles(usdzPath: String, jsonPath: String) {
        let usdzURL = URL(fileURLWithPath: usdzPath)
        let jsonURL = URL(fileURLWithPath: jsonPath)
        
        let activityVC = UIActivityViewController(activityItems: [usdzURL, jsonURL], applicationActivities: nil)
        activityVC.modalPresentationStyle = .popover

        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = exportButton
            popover.sourceRect = exportButton.bounds
        }

        present(activityVC, animated: true)
    }
}

// MARK: - Room Folder Structure
struct RoomFolder {
    private let logger = Logger(subsystem: "MenataApp", category: "RoomFolder")

    public let rootRoomFolder: URL
    public let imagesFolder: URL
    public let snapshotsFolder: URL
    public let modelsFolder: URL
    
    public init() {
        // Create root folder URL
        let documentsFolder = try! FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        rootRoomFolder = documentsFolder.appendingPathComponent("Rooms/", isDirectory: true)
        
        // Create subfolders URLs
        imagesFolder = rootRoomFolder.appendingPathComponent("Images/")
        snapshotsFolder = rootRoomFolder.appendingPathComponent("Snapshots/")
        modelsFolder = rootRoomFolder.appendingPathComponent("Models/")
        
        // Create directories
        Self.createDirectoryRecursively(rootRoomFolder)
        Self.createDirectoryRecursively(imagesFolder)
        Self.createDirectoryRecursively(snapshotsFolder)
        Self.createDirectoryRecursively(modelsFolder)
        
        print("Room folder structure created at: \(rootRoomFolder.path)")
    }
    
    static func createDirectoryRecursively(_ outputDir: URL) {
        guard outputDir.isFileURL else {
            return
        }
        
        let expandedPath = outputDir.path
        let fileManager = FileManager.default
        
        var isDirectory: ObjCBool = false
        guard !fileManager.fileExists(atPath: expandedPath, isDirectory: &isDirectory) else {
            // Directory already exists
            return
        }

        do {
            try fileManager.createDirectory(
                at: outputDir,
                withIntermediateDirectories: true,
                attributes: nil
            )
            print("Successfully created directory: \(expandedPath)")
        } catch {
            print("Failed to create directory at \(expandedPath): \(error.localizedDescription)")
        }
    }
}
