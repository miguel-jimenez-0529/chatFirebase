//
//  NewMessageController.swift
//  ChatApplication
//
//  Created by Miguel Jimenez on 8/14/17.
//  Copyright © 2017 Miguel Jimenez. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {
    
    var users = [User]()
    var messagesVC : MesssagesController?
    let celID = "CellID"

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.dissmising))
        tableView.register(UserCell.self, forCellReuseIdentifier: celID)
        fetchUser()
    }
    
    func dissmising() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func fetchUser() {
        
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            if let dic = snapshot.value as? [String : Any] {
                let user = User()
                user.setValuesForKeys(dic)
                user.id = snapshot.key
                self.users.append(user)
                self.tableView.insertRows(at: [IndexPath(row: self.users.count - 1, section: 0)], with: UITableViewRowAnimation.top)
            }
        })
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: celID, for: indexPath) as! UserCell
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        if let imageURL = user.imageURL {
            cell.profileImage.loadImageUsingCacheWithUrlString(imageURL: imageURL)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true) { 
            self.messagesVC?.showChatLog(user: self.users[indexPath.row])
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
}

class UserCell: UITableViewCell {
    
    let profileImage : UIImageView = {
       let iv = UIImageView()
        iv.backgroundColor = .red
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.cornerRadius = 20
        iv.clipsToBounds = true
        return iv
        
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 56, y: self.textLabel!.frame.origin.y - 2, width: self.textLabel!.frame.width, height: self.textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: 56, y: self.detailTextLabel!.frame.origin.y + 2, width: self.detailTextLabel!.frame.width, height: self.detailTextLabel!.frame.height)
    }
    
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImage)
        
        profileImage.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImage.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImage.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
