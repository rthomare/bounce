//  Created by Rohan Thomare on 1/1/25.

import UIKit
import Social
import SwiftUI
import UniformTypeIdentifiers
import MessageUI
import Messages

class ShareViewController: SLComposeServiceViewController {
    var hostingController: UIHostingController<BounceApp>!
    var appController: AppController!
    
    override func loadView() {
        view = UIView()
        appController = AppController.defaultFactory(onSongSelected: {
            song, type in
            if let message = MessageFactory.buildSongMessage(song) {
                self.shareViaMessages(message)
            }
        }, openURL: { URL in
            self.extensionContext?.open(URL)
        })
        let contentView = BounceApp(appController)
        hostingController = UIHostingController(rootView: contentView)
        view.addSubview(hostingController.view)
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        // Add the hostingController's view to the SLComposeServiceViewController's view
        addChild(hostingController)
        // Constrain the SwiftUI view to fit
        hostingController.didMove(toParent: self)
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self._processContexts()
        }
    }

    override func isContentValid() -> Bool {
        guard MFMessageComposeViewController.canSendText() else {
            print("This device is not configured to send messages.")
            return false
        }
        
        // Check if contentText is valid
        if let contentText = contentText, ServiceMatcher.matches(contentText) {
            return true
        }

        // Check inputItems from the extension context
        if let inputItems = extensionContext?.inputItems as? [NSExtensionItem] {
            for item in inputItems {
                if let attachments = item.attachments {
                    for attachment in attachments {
                        if attachment.hasItemConformingToTypeIdentifier("public.url") {
                            return true
                        }
                    }
                }
            }
        }
        return false
    }

    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }
    
    // MARK: Private Functions
    
    private func _processContexts() {
        // Check if contentText is valid
        if let contentText = contentText, ServiceMatcher.matches(contentText) {
            appController.handle(action: .startCreation(forUrl: contentText))
        }

        // Check inputItems from the extension context
        if let inputItems = extensionContext?.inputItems as? [NSExtensionItem] {
            for item in inputItems {
                if let attachments = item.attachments {
                    for attachment in attachments {
                        if attachment.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                            attachment.loadItem(forTypeIdentifier:UTType.url.identifier as String) { coding, error in
                                if let error {
                                    print ("Error", error)
                                    return
                                }
                                guard let url = coding as? NSURL else { return }
                                self.appController.handle(action: .startCreation(forUrl: url.absoluteString))
                            }
                        }
                    }
                }
            }
        }
    }

}

extension ShareViewController: MFMessageComposeViewControllerDelegate {
    func shareViaMessages(_ message: MSMessage) {
        guard MFMessageComposeViewController.canSendText() else {
            print("Cannot send messages.")
            return
        }

        // BREAD CRUMB
//        MessageFactory.buildSongMessage(message)
        let messageComposeVC = MFMessageComposeViewController()
        messageComposeVC.message = message
        let song = MessageFactory.getSongFromMessage(message)
        messageComposeVC.body = song?.requestSongUrl.absoluteString ?? "No song selected"
        messageComposeVC.messageComposeDelegate = self

        // Present the view controller
        self.present(messageComposeVC, animated: true, completion: nil)
    }

    // Handle the result
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)

        switch result {
        case .cancelled:
            print("Message cancelled.")
        case .sent:
            print("Message sent.")
        case .failed:
            print("Message sending failed.")
        @unknown default:
            print("Unknown result.")
        }
    }
}
