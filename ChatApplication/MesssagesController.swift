//
//  ViewController.swift
//  ChatApplication
//
//  Created by Miguel Jimenez on 8/14/17.
//  Copyright © 2017 Miguel Jimenez. All rights reserved.
//

import UIKit
import Firebase

class MesssagesController: UITableViewController {
    
    var cellID = "lfdgjsñldkfkjgs"
    var messages = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.handleLogOut))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New Message", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.handleNewMessage))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.cellID)
        checkIfUserLogged()
        observeMessages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkIfUserLogged()
    }
    
    func observeMessages() {
        let ref = FIRDatabase.database().reference().child("messages")
        ref.observe(.childAdded, with: { (snapshot) in
            print(snapshot)
            let message = Message()
            if let dic = snapshot.value as? [String : Any] {
                print(dic)
                message.setValuesForKeys(dic)
                self.messages.append(message)
                self.tableView.insertRows(at: [IndexPath(row: self.messages.count - 1, section: 0)], with: UITableViewRowAnimation.top)
            }
        })
    }
    
    func checkIfUserLogged() {
        if let uid =  FIRAuth.auth()?.currentUser?.uid {
            FIRDatabase.database().reference().child("users").child(uid)  .observeSingleEvent(of: .value, with: { (snapshot) in
                print(snapshot)
                if let dic = snapshot.value as? [String : Any] {
                    self.navigationItem.title = dic["name"] as? String
                }
            })
        }
        else {
            handleLogOut()
        }
    }
    
    func showChatLog(user : User?) {
        let chatVC = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatVC.user = user
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    
    func handleNewMessage() {
        let vc = NewMessageController()
        vc.messagesVC = self
        let nv = UINavigationController(rootViewController: vc)
        self.present(nv, animated: true, completion: nil)
    }

    func handleLogOut() {
        try! FIRAuth.auth()?.signOut()
        present(LoginController(), animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellID, for: indexPath)
        let message = self.messages[indexPath.row]
        cell.textLabel?.text = message.toID
        cell.detailTextLabel?.text = message.text
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
}

