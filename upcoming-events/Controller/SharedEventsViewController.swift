//
//  SharedEventsViewController.swift
//  upcoming-events
//
//  Created by Мария Анисович on 01.04.2025.
//

import AVFoundation
import SwifterSwift
import UIKit

final class SharedEventsViewController: UIViewController {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = "Shared Events"
        label.font = UIFont(name: "Poppins-Medium", size: 34)
        label.textColor = .black
        return label
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.setTitle("Close", for: .normal)
        button.setTitleColor(UIColor(hexString: "#5856D6"), for: .normal)
        return button
    }()
    
    private lazy var scanButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.setImage(UIImage(systemName: "qrcode.viewfinder"), for: .normal)
        button.tintColor = UIColor(hexString: "#5856D6")
        return button
    }()
    
    private lazy var importButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.setImage(UIImage(systemName: "square.and.arrow.down"), for: .normal)
        button.tintColor = UIColor(hexString: "#5856D6")
        return button
    }()
    
    private var collectionView: UICollectionView!
    
    private var events: [SharedEvent] = []
    
    private var captureSession: AVCaptureSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        events = SharedEventsStorage.loadEvents()
        
        setupTitleLabel()
        setupBackButton()
        setupScanButton()
        setupImportButton()
        setupCollectionView()
    }
    
    private func setupTitleLabel() {
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 52),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupBackButton() {
        view.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            backButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
        
        backButton.addTarget(self, action: #selector(backButtonTapped(_:)), for: .touchUpInside)
    }
    
    @objc private func backButtonTapped(_ button: UIButton) {
        dismiss(animated: true)
    }
    
    private func setupScanButton() {
        view.addSubview(scanButton)
        
        NSLayoutConstraint.activate([
            scanButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            scanButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
        
        scanButton.addTarget(self, action: #selector(scanButtonTapped(_:)), for: .touchUpInside)
    }
    
    @objc private func scanButtonTapped(_ button: UIButton) {
        requestCameraAccess { granted in
            if !granted {
                self.showCameraSettingsAlert()
                return
            }
            
            self.captureSession = AVCaptureSession()
            
            guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
                self.showAlert(message: "Camera not supported")
                return
            }
            
            guard let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else {
                self.showAlert(message: "Cannot access camera")
                return
            }
            
            if self.captureSession.canAddInput(videoInput) {
                self.captureSession.addInput(videoInput)
            } else {
                self.showAlert(message: "Cannot add camera input")
                return
            }
            
            let metadataOutput = AVCaptureMetadataOutput()
            
            if self.captureSession.canAddOutput(metadataOutput) {
                self.captureSession.addOutput(metadataOutput)
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.qr]
            } else {
                self.showAlert(message: "Cannot scan QR codes")
                return
            }
            
            let previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
            previewLayer.frame = self.view.layer.bounds
            previewLayer.videoGravity = .resizeAspectFill
            self.view.layer.addSublayer(previewLayer)
            
            DispatchQueue.global(qos: .background).async {
                self.captureSession.startRunning()
            }
        }
    }
    
    private func requestCameraAccess(completion: @escaping (Bool) -> Void) {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthorizationStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        case .restricted, .denied:
            completion(false)
        case .authorized:
            completion(true)
        @unknown default:
            completion(false)
        }
    }
    
    private func showCameraSettingsAlert() {
        let alert = UIAlertController(
            title: "Camera Access Needed",
            message: "Please enable camera access in Settings to scan QR codes.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Go to Settings", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString),
               UIApplication.shared.canOpenURL(url)
            {
                UIApplication.shared.open(url)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "QR Scanner", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func setupImportButton() {
        view.addSubview(importButton)
        
        NSLayoutConstraint.activate([
            importButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            importButton.trailingAnchor.constraint(equalTo: scanButton.leadingAnchor, constant: -15)
        ])
        
        importButton.addTarget(self, action: #selector(importButtonTapped(_:)), for: .touchUpInside)
    }
    
    @objc private func importButtonTapped(_ button: UIButton) {
        let alert = UIAlertController(title: "Import Event", message: "Paste the event code you received.", preferredStyle: .alert)
            
        alert.addTextField { textField in
            textField.placeholder = "Enter event code"
        }
            
        let importAction = UIAlertAction(title: "Import", style: .default) { _ in
            guard let code = alert.textFields?.first?.text, !code.isEmpty else {
                self.showAlert(title: "Error", message: "Event code cannot be empty.")
                return
            }
                
            if let event = SharedEvent.decodeFromString(code) {
                SharedEventsStorage.saveEvent(event)
                self.showAlert(title: "Success", message: "Event imported successfully!")
                self.events = SharedEventsStorage.loadEvents()
                self.collectionView.reloadData()
            } else {
                self.showAlert(title: "Invalid Code", message: "This code is not valid.")
            }
        }
            
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            
        alert.addAction(cancelAction)
        alert.addAction(importAction)
            
        present(alert, animated: true)
    }
    
    private func setupCollectionView() {
        var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        configuration.separatorConfiguration.bottomSeparatorInsets = .zero
        
        configuration.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self = self else { return nil }

            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, completion in
                SharedEventsStorage.deleteEvent(self.events[indexPath.item])
                self.events.remove(at: indexPath.item)
                self.collectionView.deleteItems(at: [indexPath])
                completion(true)
            }
            return UISwipeActionsConfiguration(actions: [deleteAction])
        }

        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        layout.configuration.scrollDirection = .vertical

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        
        collectionView.register(EventCollectionViewCell.self, forCellWithReuseIdentifier: "eventCollectionViewCell")
        
        view.addSubview(collectionView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 117)
        ])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession?.isRunning == true {
            captureSession.stopRunning()
        }
    }
}

extension SharedEventsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return events.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "eventCollectionViewCell", for: indexPath) as? EventCollectionViewCell else {
            fatalError("Unable to dequeue eventCollectionViewCell")
        }
        cell.configure(text: events[indexPath.item].title, remainingTime: formattedDate(date: events[indexPath.item].date))
        return cell
    }
    
    private func formattedDate(date: Date) -> String {
        let monthDayYearFormatter = DateFormatter()
        monthDayYearFormatter.dateFormat = "MMM d, yyyy"
        return monthDayYearFormatter.string(from: date)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        trailingSwipeActionsConfigurationProvider indexPath: IndexPath)
        -> UISwipeActionsConfiguration?
    {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            guard let event = self?.events[indexPath.item] else { return }
            SharedEventsStorage.deleteEvent(event)
            self?.events.remove(at: indexPath.item)
            collectionView.deleteItems(at: [indexPath])
            completion(true)
        }
           
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

extension SharedEventsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSizeMake(view.frame.width - 32, 48)
    }
}

extension SharedEventsViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection)
    {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
           let scannedString = metadataObject.stringValue
        {
            view.layer.sublayers?.removeLast()
            if let sharedEvent = SharedEvent.decodeFromString(scannedString) {
                SharedEventsStorage.saveEvent(sharedEvent)
            }
            showAlert(title: "Success", message: "Event imported successfully!")
            self.events = SharedEventsStorage.loadEvents()
            self.collectionView.reloadData()
        } else {
            showAlert(message: "Failed to scan QR code")
        }
    }
}
