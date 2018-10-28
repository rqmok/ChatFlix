//
//  GroupChatViewController.swift
//  ChatFlix
//
//  Created by Zeeshan Khan on 31/5/18.
//  Copyright © 2018 Zeeshan Khan. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
import JSQMessagesViewController

protocol removeGroupProtocol {
    func removeGroup(group: Group)
}

class GroupChatViewController: JSQMessagesViewController {
    
    // This will be passed on when friends need to be added to the group
    var addFriendsToGroupDelegate: addFriendsToGroupProtocol?
    
    // The delegate which stores the list of all groups for this user
    var removeGroupDelegate: removeGroupProtocol?
    
    // Stores the current group in which this chat is occurring
    var group: Group?
    
    // Handle to listen for new messages in Firebase
    private var messagesDatabaseHandle: DatabaseHandle?
    
    // Where the messages are stored for this group
    private var groupMessagesDatabaseRef: DatabaseReference?
    
    // Stores all Messages for this session
    private var messages = [JSQMessage]()
    
    // Stores the media items whose image needs to be downloaded
    private var movieMessageMap: [Int:JSQMediaItem] = [:]
    
    // Stores the messages as keys along with their movie ids
    private var messagesMovieIDs: [JSQMessage:Int] = [:]
    
    // Stores the movieIDs and their details
    private var movieIDDetails: [Int: Movie] = [:]
    
    // Stores the movieIDs and their image resource
    private var movieIDImageResource: [Int:ImageResource] = [:]
    
    lazy var outgoingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.outgoingMessagesBubbleImage(with: Colors.outgoingMessageBubble)
    }()
    
    lazy var incomingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.incomingMessagesBubbleImage(with: Colors.incomingMessageBubble)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let userID = Constants.currentUser.id else {
            self.displayErrorMessage("Please login to continue")
            self.navigationController?.popViewController(animated: true)
            self.navigationController?.tabBarController?.selectedIndex = 0
            return
        }
        
        guard let firstName = Constants.currentUser.firstName else {
            self.displayErrorMessage("Please login to continue")
            self.navigationController?.popViewController(animated: true)
            self.navigationController?.tabBarController?.selectedIndex = 0
            return
        }
        
        guard let lastName = Constants.currentUser.lastName else {
            self.displayErrorMessage("Please login to continue")
            self.navigationController?.popViewController(animated: true)
            self.navigationController?.tabBarController?.selectedIndex = 0
            return
        }

        // Satisfy JSQMessagesViewController
        self.senderId = userID
        self.senderDisplayName = "\(firstName) \(lastName)"
        
        // Hide the attachment button
        inputToolbar.contentView.leftBarButtonItem = nil
        
        // Ensure there are no avatars
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        // Initialise the database reference
        guard let groupID = self.group?.groupID else {
            self.displayErrorMessage("There was a problem in sending the message. Please try again later.")
            self.navigationController?.popViewController(animated: true)
            return
        }
        groupMessagesDatabaseRef = Constants.refs.databaseMessages.child(groupID)
        
        // Change title to group
        if let title = self.group?.groupName {
            self.navigationItem.title = title
        }
        
        observeMessages()
    }
    
    deinit {
        if let refHandle = messagesDatabaseHandle, let messagesRef = groupMessagesDatabaseRef {
            messagesRef.removeObserver(withHandle: refHandle)
        }
    }
    
    // Helper function that downloads a movie's details and image
    private func downloadMovieData(forMovieID movieID: Int, imageForMediaItem mediaItem: JSQPhotoMediaItem) {
        API.getMovie(id: movieID, completion: { movieData in
            if let movie = movieData, let posterPath = movie.posterPath {
                // Use kingfisher to download the image of movie
                let url = URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
                let resource = ImageResource(downloadURL: url!, cacheKey: String(movie.id))
                
                // Store the movie id and details
                self.movieIDDetails[movieID] = movie
                
                // Store the movie id and image resource
                self.movieIDImageResource[movieID] = resource
                
                KingfisherManager.shared.retrieveImage(with: resource, options: nil, progressBlock: nil) { (image, error, cacheType, imageURL) -> () in
                    // Set the media item image
                    if let downloadedImage = image {
                        mediaItem.image = downloadedImage
                    }
                    
                    // Remove the media item from map
                    self.movieMessageMap.removeValue(forKey: movieID)
                    
                    // Reload
                    self.collectionView.reloadData()
                    
                    self.scrollToBottom(animated: true)
                }
            }
        })
    }
    
    private func observeMessages() {
        if let messagesRef = groupMessagesDatabaseRef {
            let query = messagesRef.queryLimited(toLast: 50)
            
            messagesDatabaseHandle = query.observe(.childAdded, with: { messageSnapshot in
                // Decode the snapshot
                if let data = messageSnapshot.value as? NSDictionary,
                    let senderID = data.value(forKey: "senderID") as? String,
                    let senderName = data.value(forKey: "senderName") as? String,
                    let messageText = data.value(forKey: "message") as? String {
                    
                    // Check if the message is a movie reference
                    if messageText.contains(Constants.messages.movieMessagePrefix) {
                        // Use api to get movie information
                        if let movieID = Int(messageText.dropFirst(Constants.messages.movieMessagePrefix.count)) {
                            
                            // Create a new media item for the movie image
                            if let mediaItem = MovieJSQPhotoMediaItem(maskAsOutgoing: senderID == self.senderId) {
                                // Add this media item to the dictionary for later loading of image
                                self.movieMessageMap[movieID] = mediaItem
                                
                                // Add a new photo message to the list of messages
                                if let message = JSQMessage(senderId: senderID, displayName: senderName, media: mediaItem) {
                                    self.messages.append(message)
                                    
                                    // Store the jsq message and the movie id
                                    self.messagesMovieIDs[message] = movieID
                                    
                                    // Download the movie data and image using helper function
                                    self.downloadMovieData(forMovieID: movieID, imageForMediaItem: mediaItem)
                                    
                                    // Notify data change
                                    self.finishReceivingMessage()
                                }
                            }
                        }
                    } else {
                        // We have all the data. Create a new message
                        if let message = JSQMessage(senderId: senderID, displayName: senderName, text: messageText) {
                            // Append the new message
                            self.messages.append(message)
                            // Notify data change
                            self.finishReceivingMessage()
                        }
                    }
                }
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func displayErrorMessage(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // Helper function which opens the movie details view controller
    private func showMovieDetails(movie: Movie, image: ImageResource) {
        // Make sure the user can come back to this controller
        self.definesPresentationContext = true
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "MovieDetailsViewController") as! MovieDetailsViewController
        controller.movie = movie
        controller.movieImage = image
        self.navigationController?.pushViewController(controller, animated: true)
        //self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func openActionSheet(_ sender: Any) {
        // Create a new action sheet controller
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Cancel
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cancelAction)
        
        // Add Friend to Group
        let addFriendAction = UIAlertAction(title: "Add Friends", style: .default, handler: { action in
            self.performSegue(withIdentifier: "addGroupFriendSegue", sender: nil)
        })
        actionSheet.addAction(addFriendAction)
        
        // Leave Group
        let leaveGroupAction = UIAlertAction(title: "Leave Group", style: .destructive, handler: { action in
            // Leave group
            self.removeGroupDelegate?.removeGroup(group: self.group!)
            // Go back to previous controller
            self.navigationController?.popViewController(animated: true)
        })
        actionSheet.addAction(leaveGroupAction)
        
        // Present the action sheet
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        return messages[indexPath.item].senderId == senderId ? outgoingBubble : incomingBubble
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        return messages[indexPath.item].senderId == senderId ? nil : NSAttributedString(string: messages[indexPath.item].senderDisplayName)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat
    {
        return messages[indexPath.item].senderId == senderId ? 0 : 15
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        if messages[indexPath.row].isMediaMessage {
            if let movieID = self.messagesMovieIDs[self.messages[indexPath.row]] {
                // Get the movie details for this movie id and the image resource
                if let movie = self.movieIDDetails[movieID],
                    let resource = self.movieIDImageResource[movieID] {
                    // Go to the details view controller using helper function
                    self.showMovieDetails(movie: movie, image: resource)
                }
            }
        }
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        // Create message to be uploaded
        let message: [String:Any] = [
            "senderID": senderId,
            "senderName": senderDisplayName,
            "timestamp": NSDate().timeIntervalSince1970,
            "message": text
        ]
        
        // Upload the message
        if let messageRef = groupMessagesDatabaseRef {
            messageRef.childByAutoId().setValue(message)
            
            // Change the group's last message to this
            if text.hasPrefix(Constants.messages.movieMessagePrefix) == false,
                let groupID = self.group?.groupID {
                let groupRef = Constants.refs.databaseGroups.child(groupID)
                groupRef.child("lastMessage").setValue(text)
            }
        
            finishSendingMessage()
        } else {
            displayErrorMessage("There was a problem in sending the message. Please try again at another time.")
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addGroupFriendSegue" {
            let destinationVC = segue.destination as! AddGroupFriendViewController
            destinationVC.group = self.group
            destinationVC.addFriendsToGroupDelegate = self.addFriendsToGroupDelegate
        }
    }

}

// Source: https://github.com/jessesquires/JSQMessagesViewController/issues/1432
private class MovieJSQPhotoMediaItem: JSQPhotoMediaItem {
    override init!(image: UIImage!) {
        super.init(image: image)
    }
    
    override init!(maskAsOutgoing: Bool) {
        super.init(maskAsOutgoing: maskAsOutgoing)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func mediaViewDisplaySize() -> CGSize {
        if self.image != nil {
            let ratio = self.image.size.height / self.image.size.width
            let w = min(UIScreen.main.bounds.width * 0.6, self.image.size.width)
            let h = w * ratio
            return CGSize(width: w, height: h)
        } else {
            return super.mediaViewDisplaySize()
        }
    }
}
