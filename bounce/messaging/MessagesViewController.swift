//  Created by Rohan Thomare on 12/23/24.

import UIKit
import Messages
import SwiftUI
import AVFoundation

class MessagesViewController: MSMessagesAppViewController {
    var _hostingController: UIHostingController<CreateView>?
    var _flowController: CreateFlowController?
    
    func sendSongMessage(_ song: Song) {
        let message = MessageFactory.buildSongMessage(song)!
        // Send the message
        activeConversation?.insert(message, completionHandler: { error in
            if let error = error {
                print("Failed to send message: \(error.localizedDescription)")
            } else {
                print("Message sent successfully!")
            }
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create the SwiftUI view
        // Define the closure to handle song link creation
        let flowController = CreateFlowController(DefaultSongLinkRequestFactory.self) { [weak self] song in
            guard let self else { return }
            self.sendSongMessage(song)
        }
        let swiftUIView = CreateView(flowController: flowController)

        // Embed the SwiftUI view in a UIHostingController
        let hostingController = UIHostingController(rootView: swiftUIView)

        // Add the hosting controller as a child
        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)

        // Set up constraints for the hosting controller's view
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        hostingController.didMove(toParent: self)

        // Store the hosting controller for later use
        self._hostingController = hostingController
        
    }

    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.
        
        // Use this method to configure the extension and restore previously stored state.
    }
    
    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dismisses the extension, changes to a different
        // conversation or quits Messages.
        
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
    }
   
    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Called when a message arrives that was generated by another instance of this
        // extension on a remote device.
        
        // Use this method to trigger UI updates in response to the message.
    }
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.
    
        // Use this to clean up state related to the deleted message.
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called before the extension transitions to a new presentation style.
    
        // Use this method to prepare for the change in presentation style.
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.
    
        // Use this method to finalize any behaviors associated with the change in presentation style.
    }

}
