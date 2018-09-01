//
//  ListViewController.swift
//  Orbit
//
//  Created by SSY on 2018. 8. 30..
//  Copyright © 2018년 orbit. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {
    
    var models = [Model.contentsModel]()
    
    // MARK: Properties
    private var listTableView: UITableView!
    
    // MARK: IBOutlet
    @IBOutlet weak var writeButton: UIButton!
    
    // MARK: Method
    @objc fileprivate func pushWriteViewController(){
        let writeViewController = WriteViewController(delegate: self)
        self.navigationController?.pushViewController(writeViewController, animated: false)
    }

    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.writeButton.addTarget(self, action: #selector(pushWriteViewController), for: .touchUpInside)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: viewWillLayoutSubviews:
    // 뷰가 먼저 보여야하므로
    override func viewWillLayoutSubviews() {
        if self.listTableView == nil {
            self.setUpLayout()
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}

// MARK: - extension ListViewController
extension ListViewController {
    // MARK: setUpLayout
    private func setUpLayout(){
        self.listTableView = UITableView()
        self.listTableView.translatesAutoresizingMaskIntoConstraints = false
        
        let listTableViewConstraints: [NSLayoutConstraint] = [NSLayoutConstraint(item: listTableView, attribute: .top, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 0),
                                                              NSLayoutConstraint(item: listTableView, attribute: .leading, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .leading, multiplier: 1, constant: 0),
                                                              NSLayoutConstraint(item: listTableView, attribute: .trailing, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .trailing, multiplier: 1, constant: 0),
                                                              NSLayoutConstraint(item: listTableView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)]
        self.view.addSubview(listTableView)
        self.view.addConstraints(listTableViewConstraints)
        
        // ToRegister CustomCell
        self.listTableView.register(ListTableViewCell.self, forCellReuseIdentifier: "ListTableViewCell")
        self.listTableView.delegate = self
        self.listTableView.dataSource = self
    }
}
// MARK: - UITableViewDelegate
extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let writeViewcontroller = WriteViewController(delegate: self)
        self.navigationController?.pushViewController(writeViewcontroller, animated: true)
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
// MARK: - UITableViewDataSource
extension ListViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell", for: indexPath) as! ListTableViewCell
        
//        cell.model = models[indexPath.row]
        // Test
//        cell.dateLabel.text = "8월31일"
//        cell.titleLabel.text = "title"
//        cell.weekLabel.text = "금요일"
        return cell
    }

}
// MARK: - DiaryWriteDelegate
extension ListViewController: DiaryWriteDelegate {
    func writeDone() {
        // MARK: - ToDo
    }   
}
