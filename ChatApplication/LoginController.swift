//
//  LoginController.swift
//  ChatApplication
//
//  Created by Miguel Jimenez on 8/14/17.
//  Copyright © 2017 Miguel Jimenez. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {
    
    let inputsContainerView : UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view

    }()
    
    lazy var loginRegisterButton : UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Register", for: UIControlState.normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(self.handleLoginRegister), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    lazy var segmentedControl : UISegmentedControl = {
       let sc = UISegmentedControl(items: ["Login","Register"])
        sc.tintColor = UIColor.white
        sc.selectedSegmentIndex = 1
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.addTarget(self, action: #selector(handleToggle), for: .valueChanged)
        return sc
    }()
    
    func handleToggle() {
        containerViewHeightAnchr?.isActive = false
        containerViewHeightAnchr = inputsContainerView.heightAnchor.constraint(equalToConstant: segmentedControl.selectedSegmentIndex == 0 ? 100 : 150)
        containerViewHeightAnchr?.isActive = true
        
        nameTextField.isHidden = segmentedControl.selectedSegmentIndex == 0
        
        nameTextFieldHeightAnchr?.isActive = false
        nameTextFieldHeightAnchr = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: segmentedControl.selectedSegmentIndex == 0 ? 0 : 1/3)
        nameTextFieldHeightAnchr?.isActive = true

        emailTextFieldHeightAnchr?.isActive = false
        emailTextFieldHeightAnchr = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: segmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        emailTextFieldHeightAnchr?.isActive = true
        
        passTextFieldHeightAnchr?.isActive = false
        passTextFieldHeightAnchr = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: segmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passTextFieldHeightAnchr?.isActive = true
        
        loginRegisterButton.setTitle(segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex), for: .normal)
        
    }
    
    func handleLoginRegister() {
        if segmentedControl.selectedSegmentIndex == 0 {
            handleLogin()
        }
        else {
            handleRegister()
        }
    }
    
    func handleLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("Values needed")
            return
        }
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user , error) in
            if error != nil {
                print(error!)
                let alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let action = UIAlertAction(title: "Cerrar", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                return
            }
            //Successfully loged in
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func handleRegister() {
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {
            print("Values needed")
            return
        }
        
        guard let image = self.profileImage.image else {
            print("Image nil")
            return
        }
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user : FIRUser?, error) in
            if error != nil {
                print(error!)
                let alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let action = UIAlertAction(title: "Cerrar", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            guard let uid = user?.uid else {
                return
            }
            let imageName = UUID().uuidString
            let storageRef = FIRStorage.storage().reference().child("\(imageName).jpg")
            
            if let data  = UIImageJPEGRepresentation(image, 0.1) {
                storageRef.put(data, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        print(error!)
                        let alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                        let action = UIAlertAction(title: "Cerrar", style: .default, handler: nil)
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                    
                    let ref = FIRDatabase.database().reference(fromURL: "https://chatapplication-d155b.firebaseio.com/")
                    let usersRef = ref.child("users").child(uid)
                    let values : [String : Any] = ["name": name, "email" : email, "password" : password, "imageURL" : metadata?.downloadURL()?.absoluteString ?? "nil"]
                    usersRef.updateChildValues(values, withCompletionBlock: { (error, ref) in
                        if error != nil {
                            print(error!)
                            let alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                            let action = UIAlertAction(title: "Cerrar", style: .default, handler: nil)
                            alert.addAction(action)
                            self.present(alert, animated: true, completion: nil)
                            return
                        }
                        print("Saved User Succesfully in DB")
                        self.dismiss(animated: true, completion: nil)
                    })
                    
                })
            }
        })
    }
    
    
    let nameTextField : UITextField = {
       let tf = UITextField ()
        tf.placeholder = "Name"
        tf.autocorrectionType = .no
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let nameSeparatorView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    let emailTextField : UITextField = {
        let tf = UITextField ()
        tf.placeholder = "Email"
        tf.keyboardType = UIKeyboardType.emailAddress
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        return tf
    }()
    
    let emailSeparatorView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    let passwordTextField : UITextField = {
        let tf = UITextField ()
        tf.placeholder = "Password"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isSecureTextEntry = true
        return tf
    }()
    
    let passwordSeparatorView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var profileImage : UIImageView = {
       let iv = UIImageView()
        iv.backgroundColor = .red
        iv.translatesAutoresizingMaskIntoConstraints = false
        let tap = UITapGestureRecognizer(target : self, action : #selector(handleAddImage))
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(tap)
        return iv
    }()
    
    func handleAddImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        view.addSubview(inputsContainerView)
        view.addSubview(loginRegisterButton)
        view.addSubview(segmentedControl)
        view.addSubview(profileImage)
        
        setUpInputsContainerView()
        setLoginRegisterButton()
        setUpProfileImage()
        setUpSegmentedControl()
        
    }
    
    var containerViewHeightAnchr : NSLayoutConstraint?
    var nameTextFieldHeightAnchr : NSLayoutConstraint?
    var emailTextFieldHeightAnchr : NSLayoutConstraint?
    var passTextFieldHeightAnchr : NSLayoutConstraint?
    
    
    func setUpSegmentedControl() {
        segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        segmentedControl.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant : -12).isActive = true
        segmentedControl.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        segmentedControl.heightAnchor.constraint(equalToConstant: 36)
    }
    
    func setUpProfileImage() {
        profileImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImage.bottomAnchor.constraint(equalTo: segmentedControl.topAnchor, constant: -12).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImage.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    func setLoginRegisterButton() {
        loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor , constant : 12).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setUpInputsContainerView() {
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant : -24).isActive = true
        containerViewHeightAnchr = inputsContainerView.heightAnchor.constraint(equalToConstant: 150)
        containerViewHeightAnchr?.isActive = true
        
        //Name
        inputsContainerView.addSubview(nameTextField)
        inputsContainerView.addSubview(nameSeparatorView)
        
        nameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant : 12).isActive = true
        nameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        nameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameTextFieldHeightAnchr =  nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        nameTextFieldHeightAnchr?.isActive = true
        
        nameSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        nameSeparatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameSeparatorView.heightAnchor.constraint(equalToConstant:1).isActive = true
        
        //Email
        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(emailSeparatorView)
        
        emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant : 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailTextFieldHeightAnchr =   emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        emailTextFieldHeightAnchr?.isActive = true
        
        emailSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailSeparatorView.heightAnchor.constraint(equalToConstant:1).isActive = true
        
        //Pass
        inputsContainerView.addSubview(passwordTextField)
        inputsContainerView.addSubview(passwordSeparatorView)
        
        passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant : 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passTextFieldHeightAnchr = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        passTextFieldHeightAnchr?.isActive = true

        passwordSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        passwordSeparatorView.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor).isActive = true
        passwordSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordSeparatorView.heightAnchor.constraint(equalToConstant:1).isActive = true
        
    }
}

extension LoginController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profileImage.image = image
            profileImage.contentMode = .scaleAspectFill
        }
         self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension UIColor {
    
    convenience init(r: CGFloat, g : CGFloat , b : CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}
