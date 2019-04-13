
import UIKit
import RealmSwift

final class MemoCollectionTableView : UIViewController {
    
    
    private var realmManager = RealmManager.shared.realm
    var datasourece : Results<Content>!
    
    private var memoTableView : UITableView!
    private var spacingView : UIView!
    private var spacingInnerView : UIView!
    
    fileprivate var backButton : UIImageView = UIImageView()
    
    override func viewDidLoad() {
        navigationController?.navigationBar.barTintColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.hidesBackButton = true
        navigationItem.title = "나의 메모"
        self.view.backgroundColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
        datasourece = realmManager.objects(Content.self).sorted(byKeyPath: "createdAt", ascending: false).filter("type == 'memo'")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNavigationBackButton(onView: self, in: backButton, bool: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        memoTableView.reloadData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        setNavigationBackButton(onView: self, in: backButton, bool: false)
    }
    
    override func viewWillLayoutSubviews() {
        if memoTableView == nil {
            setupUI()
        }
    }
}

extension MemoCollectionTableView : UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension MemoCollectionTableView : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let datasources = datasourece.count
        return datasources
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "memoCollectionTableViewCell", for: indexPath) as! MemoCollectionTableViewCell
        let row = indexPath.row
        let data = datasourece[row]
        let createAt = dateToString(in: data.createdAt, dateFormat: "yyyy.MM.dd eee")
        cell.dateLabel.text = createAt
        cell.contents.text = data.body
        return cell
    }
}

extension MemoCollectionTableView {
    func setupUI() {
        let height = self.navigationController?.navigationBar.bounds.height
        let window = UIApplication.shared.keyWindow
        let safePadding = window?.safeAreaInsets.top
        let heightPadding = CGFloat(height!) + CGFloat(safePadding!)
        
        spacingView = UIView()
        spacingInnerView = UIView()
        memoTableView = UITableView()
        
        spacingView.translatesAutoresizingMaskIntoConstraints = false
        memoTableView.translatesAutoresizingMaskIntoConstraints = false
        spacingInnerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(spacingView)
        spacingView.addSubview(spacingInnerView)
        view.addSubview(memoTableView)
        
        spacingView.topAnchor.constraint(equalTo: view.topAnchor, constant: heightPadding).isActive = true
        spacingView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        spacingView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        spacingView.heightAnchor.constraint(equalToConstant: 5).isActive = true
        
        spacingInnerView.topAnchor.constraint(equalTo: spacingView.topAnchor,
                                              constant: 0).isActive = true
        spacingInnerView.leadingAnchor.constraint(equalTo: spacingView.leadingAnchor,
                                                  constant: 0).isActive = true
        spacingInnerView.trailingAnchor.constraint(equalTo: spacingView.trailingAnchor,
                                                   constant: 0).isActive = true
        spacingInnerView.heightAnchor.constraint(equalToConstant: 5).isActive = true
        spacingInnerView.backgroundColor = #colorLiteral(red: 0.1843137255, green: 0.1411764706, blue: 0.1333333333, alpha: 0.199261582)
        
        memoTableView.topAnchor.constraint(equalTo: spacingView.bottomAnchor, constant: 0).isActive = true
        memoTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        memoTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        memoTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        memoTableView.register(MemoCollectionTableViewCell.self, forCellReuseIdentifier: "memoCollectionTableViewCell")
        
        memoTableView.delegate = self
        memoTableView.dataSource = self
        memoTableView.backgroundColor = .clear
        memoTableView.separatorStyle = .none
        memoTableView.allowsSelection = false
    }
}

