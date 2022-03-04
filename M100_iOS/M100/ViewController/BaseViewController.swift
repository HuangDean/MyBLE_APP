import UIKit
import RxSwift

class BaseViewController: UIViewController {

    internal var parentVC: BaseViewController!
    
    internal var navBar: UINavigationBar!
    internal var backButton: UIButton!
    internal var maskView: UIView!
    internal var actInd: UIActivityIndicatorView!

    internal var screenHeight: CGFloat!
    internal var screenWidth: CGFloat!
    internal var baseRate: CGFloat!
    internal var rate: CGFloat!
    
    internal let baseViewModel = BaseViewModel()
    
    internal var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white

        navBar = navigationController?.navigationBar
        
        screenWidth = UIScreen.main.bounds.size.width
        screenHeight = UIScreen.main.bounds.size.height
        
        // iphone 6
        baseRate = 667 / 375
        rate = screenHeight / screenWidth / baseRate
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disposeBag = DisposeBag()
    }
    
    func initNavigationBar(barTintColor: UIColor, tintColor: UIColor) {
        self.navigationController?.navigationBar.barTintColor = barTintColor
        self.navigationController?.navigationBar.tintColor = tintColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: tintColor]
    }

    func setBackButton(imgNamed: String, title: String) {
        let backButtonImage = UIImage(named: imgNamed)
        backButton = UIButton(type: .custom)
        backButton.imageView?.contentMode = .scaleAspectFit
        backButton.setImage(backButtonImage, for: .normal)
        backButton.setImage(backButtonImage, for: .highlighted)
        backButton.setTitle(title, for: .normal)
        backButton.titleLabel?.adjustsFontSizeToFitWidth = true
        backButton.setTitleColor(.black, for: .normal)
        backButton.addTarget(self, action: #selector(self.backButtonPressed), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }

    @objc func backButtonPressed() {
        // dissmiss animated right to left
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        self.view.window!.layer.add(transition, forKey: nil)
        self.dismiss(animated: false, completion: nil)
//        self.dismiss(animated: true, completion: nil)
    }

    func presentDeletionAlert(title: String) {
        let alertController = UIAlertController(title: nil, message: title, preferredStyle: .alert)

        let deleteAction = UIAlertAction(title: getResString("delete"), style: .destructive) { _ in

        }
        alertController.addAction(deleteAction)

        let cancelAction = UIAlertAction(title: getResString("cancel"), style: .cancel)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }

    func presentViewController(viewController: UIViewController) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
//        present(dashboardWorkout, animated: false, completion: nil)
        
        let navVC = UINavigationController(rootViewController: viewController)
        navVC.view.backgroundColor = .white
        navVC.modalPresentationStyle = .overCurrentContext
        self.present(navVC, animated: false, completion: nil)
    }
    
    func presentViewController(viewController: UIViewController, isOverContext: Bool) {
        let navVC = UINavigationController(rootViewController: viewController)
        navVC.view.backgroundColor = .white
        
        if isOverContext {
            navVC.modalPresentationStyle = .overCurrentContext
        }
        self.present(navVC, animated: true, completion: nil)
    }

    func pushViewController(viewController: UIViewController) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    func showIndicator() {
        if maskView == nil {
            maskView = UIView()
            maskView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(maskView)

            let actIndBgView = UIView()
            actIndBgView.translatesAutoresizingMaskIntoConstraints = false
            maskView.addSubview(actIndBgView)
            actIndBgView.backgroundColor = UIColor(white: 0.7, alpha: 0.7)
            actIndBgView.clipsToBounds = true
            actIndBgView.layer.cornerRadius = 10

            if #available(iOS 13.0, *) {
                actInd = UIActivityIndicatorView(style: .large)
            } else {
                actInd = UIActivityIndicatorView(style: .gray)
            }
            actInd.translatesAutoresizingMaskIntoConstraints = false
            actIndBgView.addSubview(actInd)
            actInd.hidesWhenStopped = true

            self.view.addSubview(maskView)

            NSLayoutConstraint.activate([
                maskView.topAnchor.constraint(equalTo: self.view.topAnchor),
                maskView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
                maskView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
                maskView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),

                actIndBgView.widthAnchor.constraint(equalToConstant: screenWidth / 3.5),
                actIndBgView.heightAnchor.constraint(equalToConstant: screenWidth / 3.5),
                actIndBgView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
                actIndBgView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),

                actInd.centerYAnchor.constraint(equalTo: actIndBgView.centerYAnchor),
                actInd.centerXAnchor.constraint(equalTo: actIndBgView.centerXAnchor)
                ])
        }

        self.maskView.isHidden = false
        self.actInd.startAnimating()
    }

    func hideIndicator() {
        if maskView != nil {
            maskView.isHidden = true
            actInd.stopAnimating()
        }
    }

    func showAlert(msg: String) {
        let controller = UIAlertController(title: "", message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: getResString("confirm"), style: .default, handler: nil)
        controller.addAction(okAction)
        present(controller, animated: true, completion: nil)
    }
    
    /// 顯示Alert
    /// - Parameters:
    ///   - title: 標題
    ///   - msg: 內容
    ///   - isCancelAction: 是否有取消鍵
    ///   - textAlignment: 對齊方式
    ///   - handler: call back
    func showAlert(title: String? = "",
                   msg: String,
                   isCancelAction: Bool = false,
                   textAlignment: NSTextAlignment = .center,
                   handler: (() -> Void)? = nil) {
        let controller = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        if #available(iOS 13.0, *) {
            controller.overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        
        let okAction = UIAlertAction(title: getResString("update_now"), style: .default, handler: { UIAlertAction in
            if let handler = handler {
                handler()
            }
        })
        
        controller.addAction(okAction)
        
        if isCancelAction {
            let cancelAction = UIAlertAction(title: getResString("later"), style: .cancel, handler: nil)
            controller.addAction(cancelAction)
        }
        
        if textAlignment != .center {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = textAlignment
            let messageText = NSMutableAttributedString(
                string: msg,
                attributes: [
                    NSAttributedString.Key.paragraphStyle: paragraphStyle,
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13)
                ]
            )
            controller.setValue(messageText, forKey: "attributedMessage")
        }
        
        present(controller, animated: true, completion: nil)
    }
    
    func showToast(msg: String) {
        self.view.makeToast(msg, duration: 2.0, position: .center)
    }
    
    func setStatusBarColor(color: UIColor) {
        if #available(iOS 13.0, *) {
            let app = UIApplication.shared
            let statusBarHeight: CGFloat = app.statusBarFrame.size.height
            
            let statusbarView = UIView()
            statusbarView.backgroundColor = color
            view.addSubview(statusbarView)
            
            statusbarView.translatesAutoresizingMaskIntoConstraints = false
            statusbarView.heightAnchor.constraint(equalToConstant: statusBarHeight).isActive = true
            statusbarView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0).isActive = true
            statusbarView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            statusbarView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        } else {
            let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
            statusBar?.backgroundColor = color
        }
    }
    
    func getResColor(_ key: String) -> UIColor {
        return UIColor.init(named: key) ?? UIColor.clear
    }
    
    func getResImage(_ key: String?) -> UIImage? {
        if let key = key {
            return UIImage(named: key)
        }
        
        return nil
    }
    
    func getResString(_ key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }
    
    func getFontSize(_ size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size)
    }
    
    func didReAppear() {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}

extension DispatchQueue {

    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }

}
