//
//  LoginVC.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 15.02.2021.
//

import UIKit

protocol AuthenticationDelegate: class {
    func authenticationDidComplete()
}


class LoginController: UIViewController {

    // MARK: - Properties
    
    weak var delegate: AuthenticationDelegate?
    
    
    // MARK: Views
    
    // create a stackView to hold some object inside the stack
    private let objectStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        return stack
    }()
    
    // create application icon
    private let appIconImage: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "appIcon"))
        iv.contentMode = .scaleAspectFill
        // round corner
        iv.layer.cornerRadius = 10
        iv.clipsToBounds = true
        return iv
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
    
    // creating logIn button
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.createSignButton(buttonLabel: "Log In")
        button.addTarget(self, action: #selector(loginButton_clicked), for: .touchUpInside)
        return button
    }()
    
    // creating Forgot your password? Get help signing in. button with extension function
    private let forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.attributedTitle(firstPart: "Forgot your password? ", secondPart: "Get help signing in.")
        return button
    }()
    
    // creating Don't have an account? Sign Up Button with extension function to go to RegistrationVC
    private let dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.attributedTitle(firstPart: "Don't have an account?  ", secondPart: "Sign Up")
        button.addTarget(self, action: #selector(handleShowSignUpButton_clicked), for: .touchUpInside)
        return button
    }()
    
    
    //MARK: - LifeCycle

    // executed once the Auto-Layout has been applied / executed
    override func viewDidLoad() {
        super.viewDidLoad()

        // declare all auto layout
        configureUI()
        
        // add observer to get enable func of LogIn Button
        configureNotificationObservers()
    }
    
    
    // executed EVERYTIME when view will appear to the screen
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    // executed EVERYTIME when view did disappear from the screen
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        // switch off notification center, so it wouldn't in action / running
//        NotificationCenter.default.removeObserver(self)
        
    }
    
    
    //MARK: - API
    
    
    
    // MARK: - Action
    
    // executed always when the Screen's White Space (anywhere excluding objects) tapped
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // end editing - hide keyboards
        self.view.endEditing(false)
    }
    

    // executed when the login button is pressed
    @objc func loginButton_clicked() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        
        AuthService.logUserIn(email: email, password: password, selfVC: self, isLoginVC: true) { error in
            if let err = error {
                print("DEBUG: Failed to log user in \(err.localizedDescription)")
                return
            }
            
        }
        
    }
    
    // executed when the Show Sign Up button is pressed
    @objc func handleShowSignUpButton_clicked() {
        let controller = RegistrationController()
//        controller.delegate = delegate
        navigationController?.pushViewController(controller, animated: true)
        
    }
    
    // execute whenever texts change in the textField which are declared below
    @objc func textDidChange() {
        
        // execute custom function to enable Log In Button
        if Helper().isValid(email: emailTextField.text!) && passwordTextField.text!.count > 5 {
            loginButton.enableSignButton()
        } else {
            loginButton.createSignButton(buttonLabel: "Log In")
        }
        
    }
    
    
    // MARK: - Helpers
    
    // declaring UI obj auto layout properties
    func configureUI() {
        // declare the background color of the screen
        self.view.backgroundColor = UIColor(named: K.Screen.backGroundColor)
        // hide navigation bar
        navigationController?.navigationBar.isHidden = true
        
        // fetch screen height to use while layout
        let height = self.view.frame.height
        
        // create iconView to maintain the size of appIconImage
        let iconView = UIView()
        iconView.setHeight(80)
        
        // placing appIconImage in the iconView
        iconView.addSubview(appIconImage)
        // declaring appIconImage size attibributes
        appIconImage.center(inView: iconView)
        appIconImage.setDimensions(height: 80, width: 80)
        
        // adding views in the stackView in order to create auto layout
        objectStackView.addArrangedSubview(iconView)
        objectStackView.addArrangedSubview(emailTextField)
        objectStackView.addArrangedSubview(passwordTextField)
        objectStackView.addArrangedSubview(loginButton)
        objectStackView.addArrangedSubview(forgotPasswordButton)

        // stackView auto layout properties
        view.addSubview(objectStackView)
        objectStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                     left: view.safeAreaLayoutGuide.leftAnchor,
                     right: view.safeAreaLayoutGuide.rightAnchor,
                     paddingTop: height*0.05, paddingLeft: 30, paddingRight: 30)
        
        // declaring dontHaveAccountButton auto layout properties
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.centerX(inView: view)
        dontHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor)
    }
    
    
    // adding observer in order to decide button isEnable = true
    func configureNotificationObservers() {
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
   

}



