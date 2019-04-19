

import UIKit
import EFMarkdown

class OpensourceLicenseVC : UIViewController {
 
    
    var openSources : EFMarkdownView!
    private var spacingView : UIView!
    private var spacingInnerView : UIView!
    var backButton : UIImageView = UIImageView()
    
    override func viewDidLoad() {
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.hidesBackButton = true
        navigationItem.title = "Open source License"
        view.backgroundColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNavigationBackButton(onView: self, in: backButton, bool: true)
        setupLayout()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        setNavigationBackButton(onView: self, in: backButton, bool: false)
    }
    
    func setupLayout() {
        let height = self.navigationController?.navigationBar.bounds.height
        let window = UIApplication.shared.keyWindow
        let safePadding = window?.safeAreaInsets.top
        let heightPadding = CGFloat(height!) + CGFloat(safePadding!)
        
        spacingView = UIView()
        spacingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spacingView)
        
        spacingView.topAnchor.constraint(equalTo: view.topAnchor, constant: heightPadding).isActive = true
        spacingView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        spacingView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        spacingView.heightAnchor.constraint(equalToConstant: 5).isActive = true
        
        spacingInnerView = UIView()
        spacingInnerView.translatesAutoresizingMaskIntoConstraints = false
        spacingView.addSubview(spacingInnerView)
        
        spacingInnerView.topAnchor.constraint(equalTo: spacingView.topAnchor, constant: 0).isActive = true
        spacingInnerView.leadingAnchor.constraint(equalTo: spacingView.leadingAnchor, constant: 0).isActive = true
        spacingInnerView.trailingAnchor.constraint(equalTo: spacingView.trailingAnchor, constant: 0).isActive = true
        spacingInnerView.heightAnchor.constraint(equalToConstant: 5).isActive = true
        spacingInnerView.backgroundColor = #colorLiteral(red: 0.1843137255, green: 0.1411764706, blue: 0.1333333333, alpha: 0.199261582)
        
        openSources = EFMarkdownView()
        openSources.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(openSources)
        
        openSources.topAnchor.constraint(equalTo: spacingView.bottomAnchor, constant: 0).isActive = true
        openSources.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        openSources.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        openSources.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        
        openSources.onRendered = {
            [weak self] (height) in
            if let _ = self {
                
            }
        }
        
        openSources.load(markdown: openMarkdown(), options: [.default]) { [weak self](_, _) in
            if let _ = self {
                self!.openSources.setFontSize(percent: 100)
            }
        }
    }
    
    public func openMarkdown() -> String {
        if let templateURL = Bundle.main.url(forResource: "opensourceLicense", withExtension: "md") {
            do {
                return try String(contentsOf: templateURL, encoding: String.Encoding.utf8)
            } catch {
                return ""
            }
        }
        return ""
    }
//    private var licenseTableView : UITableView!
//
//
//    override func viewDidLoad() {
//        self.navigationController?.navigationBar.barTintColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
//        self.navigationController?.navigationBar.prefersLargeTitles = true
//        self.navigationItem.largeTitleDisplayMode = .automatic
//        self.navigationItem.title = "오픈소스 라이선스"
//        self.navigationItem.hidesBackButton = true
//
//    }
//
//    func setTableView() {
//        licenseTableView = UITableView()
//
//        licenseTableView.translatesAutoresizingMaskIntoConstraints = false
//
//        licenseTableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
//        licenseTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
//        licenseTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
//        licenseTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
//    }
//}
//
//extension OpensourceLicenseVC : UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = UITableViewCell()
//        return cell
//    }
//
    
}

