//
//  RegistrationVC.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 15.02.2021.
//

import UIKit
import Alamofire

class RegistrationController: UIViewController {

    // MARK: - Properties
    
    
    // MARK: UI Obj
    
    private let objectStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        return stack
    }()
    
    // creating email textField
    private let emailTextField: UITextField = {
        let tf = LoginAndRegistrationTextField(placeholder: "Email")
        tf.keyboardType = .emailAddress
        return tf
    }()
    

    // creating password textField
    private let passwordTextField: UITextField = {
        let tf = LoginAndRegistrationTextField(placeholder: "Password")
        tf.isSecureTextEntry = true
        return tf
    }()
    
    // creating userName textField
    private let usernameTextField = LoginAndRegistrationTextField(placeholder: "Username")
    
    // creating firstName textField
    private let firstNameTextField = LoginAndRegistrationTextField(placeholder: "Firstname")
    
    // creating lastName textField
    private let lastNameTextField = LoginAndRegistrationTextField(placeholder: "Lastname")
    
    
    // creating logIn button
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.createSignButton(buttonLabel: "Sign Up")
        button.addTarget(self, action: #selector(signUpButton_clicked), for: .touchUpInside)
        return button
    }()
    
    // creating Don't have an account? Sign Up Button with extension function to go to RegistrationVC
    private let alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.attributedTitle(firstPart: "Already have an account?  ", secondPart: "Log In")
        button.addTarget(self, action: #selector(alreadyHaveAnAccountButton_clicked), for: .touchUpInside)
        return button
    }()
    
    // create application icon
    
    
    //MARK: - LifeCycle

    // executed once the Auto-Layout has been applied / executed
    override func viewDidLoad() {
        super.viewDidLoad()

        // declare all auto layout
        configureUI()
        
        // add observer to get enable func of SignUp Button
        configureNotificationObservers()
    }
    
    
    //MARK: - API
    
    
    
    // MARK: - Action
    
    // executed always when the Screen's White Space (anywhere excluding objects) tapped
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // end editing - hide keyboards
        self.view.endEditing(false)
    }
    
    // This function is executed whenever Sign Up button has been clicked
    @objc func signUpButton_clicked() {
        
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let firstName = firstNameTextField.text else { return }
        guard let lastName = lastNameTextField.text else { return }
        guard let userName = usernameTextField.text?.lowercased() else { return }
        let fullName = "\(firstName) \(lastName)"
        
        let credentials = AuthCreditentials(email: email, password: password, fullName: fullName, userName: userName)
        
        AuthService.registerUser(withCredentials: credentials, selfVC: self, isLoginVC: false) { error in
            if let error = error {
                print("DEBUG: Failed to register user \(error.localizedDescription.utf8)")
                return
            }
            
        }
        
    }
    
    // go back to the LoginVC
    @objc func alreadyHaveAnAccountButton_clicked() {
        navigationController?.popViewController(animated: true)
    }
    
    
    // execute whenever texts change in the textField which are declared below
    @objc func textDidChange(sender: UITextField) {
        
        // declaring constant (shortcut) to the Helper Struct
        let helper = Helper()
        
        // execute custom function to enable Log In Button
        if helper.isValid(email: emailTextField.text!) && passwordTextField.text!.count > 5 && helper.isValid(name: firstNameTextField.text!) && helper.isValid(name: lastNameTextField.text!) && helper.isValid(userName: usernameTextField.text!) {
            // enable Sign Up button
            signUpButton.enableSignButton()
        } else {
            // disable Sign Up button
            signUpButton.createSignButton(buttonLabel: "Sign Up")
        }
        
    }
    
    // MARK: - Helpers

    
    // declaring UI obj auto layout
    func configureUI() {
        // declare the background color of the screen
        self.view.backgroundColor = UIColor(named: K.Screen.backGroundColor)
        
        // fetch screen height to use while layout
        let height = self.view.frame.size.height
        
                
        // adding views in the stackView in order to maintain auto layout
        objectStackView.addArrangedSubview(emailTextField)
        objectStackView.addArrangedSubview(passwordTextField)
        objectStackView.addArrangedSubview(usernameTextField)
        objectStackView.addArrangedSubview(firstNameTextField)
        objectStackView.addArrangedSubview(lastNameTextField)
        objectStackView.addArrangedSubview(signUpButton)

        // stackView is added in the self.view and declaring stackView auto layout properties
        view.addSubview(objectStackView)
        objectStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                     left: view.safeAreaLayoutGuide.leftAnchor,
                     right: view.safeAreaLayoutGuide.rightAnchor,
                     paddingTop: height*0.05, paddingLeft: 30, paddingRight: 30)
        
        // alreadyHaveAccountButton is added in the self.view and declaring alreadyHaveAccountButton auto layout properties
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.centerX(inView: view)
        alreadyHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor)
    }
    
    
    // adding observer in order to decide button isEnable = true
    func configureNotificationObservers() {
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        usernameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        firstNameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        lastNameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    
    
}
