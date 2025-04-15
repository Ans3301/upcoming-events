//
//  ShareEventViewController.swift
//  upcoming-events
//
//  Created by Мария Анисович on 27.03.2025.
//

import CoreImage.CIFilterBuiltins
import MessageUI
import UIKit

final class ShareEventViewController: UIViewController {
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.setTitle("Close", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = "Share Event"
        label.font = UIFont(name: "Poppins-Medium", size: 34)
        label.textColor = .black
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        return tableView
    }()
    
    var event: SharedEvent?
    
    private var shareTypes = ["Email", "Message", "QRCode"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupBackButton()
        setupTitleLabel()
        setupTableView()
    }
    
    private func setupBackButton() {
        view.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 15),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
        
        backButton.addTarget(self, action: #selector(backButtonTapped(_:)), for: .touchUpInside)
    }
    
    @objc private func backButtonTapped(_ button: UIButton) {
        dismiss(animated: true)
    }
    
    private func setupTitleLabel() {
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.widthAnchor.constraint(equalTo: view.widthAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 52)
        ])
    }
    
    private func setupTableView() {
        tableView.register(ShareTypeTableViewCell.self, forCellReuseIdentifier: "shareTypeTableViewCell")
        
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}

extension ShareEventViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shareTypes.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "shareTypeTableViewCell") as? ShareTypeTableViewCell else {
            fatalError("Unable to dequeue OperationCollectionViewCell")
        }
        cell.configure(text: shareTypes[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if shareTypes[indexPath.row] == "Email" {
            sendEmail()
        } else if shareTypes[indexPath.row] == "Message" {
            sendMessage()
        } else if shareTypes[indexPath.row] == "QRCode" {
            let qrCodeViewController = QRCodeViewController()
            qrCodeViewController.qrCodeImage = generateQRCode()
            qrCodeViewController.modalPresentationStyle = .overFullScreen
            qrCodeViewController.modalTransitionStyle = .crossDissolve
            present(qrCodeViewController, animated: true)
        }
    }

    private func sendEmail() {
        guard let event = event, let encodedString = event.encodeToString() else { return }
        
        guard MFMailComposeViewController.canSendMail() else {
            showAlert(title: "Email Unavailable", message: "Please configure your Mail app.")
            return
        }
            
        let mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = self
        mailVC.setSubject("Event Invitation: \(event.title)")
        let body = "Hey,\n\nJoin me for this event:\n\n**\(event.title)**\n📅 \(event.date)\n\nUse this event code to add it in the app:\n\(encodedString)\n\nSee you there!"
        mailVC.setMessageBody(body, isHTML: false)
            
        present(mailVC, animated: true)
    }
    
    private func sendMessage() {
        guard let event = event, let encodedString = event.encodeToString() else { return }
        
        guard MFMessageComposeViewController.canSendText() else {
            showAlert(title: "Messaging Unavailable", message: "Your device does not support SMS.")
            return
        }
            
        let messageVC = MFMessageComposeViewController()
        messageVC.messageComposeDelegate = self
        messageVC.body = "Join me for \(event.title) on \(event.date).\nEvent Code: \(encodedString)"
            
        present(messageVC, animated: true)
    }
    
    private func generateQRCode() -> UIImage? {
        guard let event = event, let encodedString = event.encodeToString() else { return nil }
        
        let data = Data(encodedString.utf8)
        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(data, forKey: "inputMessage")
        if let outputImage = filter.outputImage {
            let transformed = outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
            return UIImage(ciImage: transformed)
        }
        return nil
    }
}

extension ShareEventViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension ShareEventViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true)
    }
}
