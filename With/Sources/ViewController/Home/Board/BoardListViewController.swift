//
//  BoardListViewController.swift
//  With
//
//  Created by 남수김 on 2020/01/01.
//  Copyright © 2020 ns. All rights reserved.
//

import UIKit
import FMDB
import Lottie
class BoardListViewController: UIViewController {
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var regionButton: UIButton!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var switchButton: UISwitch!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchHistoryTableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchCancelButton: UIButton!
    @IBOutlet weak var searchAreaView: UIView!
    @IBOutlet weak var lottieLoading: AnimationView!
    
    @IBOutlet weak var searchAreaRightLayout: NSLayoutConstraint!
    var regionString: String = "전체"
    var regionCode = "0"
    var dateString: String = "날짜"
    var sDate = "0"
    var eDate = "0"
    var filterNum = 0
    var word = "0"
    var boardList: [BoardResult] = []
    var historyList: [SearchData] = []
    
    var fileURL: URL!
    var database: FMDatabase!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        // 처음인 경우 지역설정
        if UserInfo.shared.isNotDefaultRegion() {
            let nextVC = UIStoryboard(name: "RegionFilter", bundle: nil).instantiateViewController(withIdentifier: "RegionFilter") as! RegionFilterViewController
            nextVC.delegate = self
            self.present(nextVC, animated: true)
        } else {
            self.regionCode = UserDefaults.standard.string(forKey: "regionCode") ?? "010000"
            self.regionString = UserDefaults.standard.string(forKey: "regionName") ?? "전체"
            self.regionButton.setTitle(regionString, for: .normal)
        }
        setDefaultRequest()
        
               
        
    }
    override func viewWillAppear(_ animated: Bool) {
        setDB()
        selectQuery()
        if let index = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: index, animated: true)
        }
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.database.close()
    }
    
    func setDefaultRequest() {
        BoardService.shared.getBoardListRequest(code: regionCode) { data in
            if data == nil {
                self.lottieLoading.stop()
                self.lottieLoading.isHidden = true
                self.simpleAlert(title: "Error", msg: "해당 데이터가 없습니다.")
            } else {
                self.boardList = data!
                self.tableView.reloadData()
                self.lottieLoading.stop()
                self.lottieLoading.isHidden = true
            }
        }
    }
    
    func setUI() {
        self.topView.dropShadow()
        self.regionButton.layer.borderWidth = 1
        self.dateButton.layer.borderWidth = 1
        self.dateButton.layer.borderColor = UIColor.mainPurple.cgColor
        self.regionButton.layer.borderColor = UIColor.mainPurple.cgColor
        self.regionButton.layer.cornerRadius = 6
        self.dateButton.layer.cornerRadius = 6
        self.dateButton.setTitle(dateString, for: .normal)
        self.regionButton.setTitle(regionString, for: .normal)
        
        self.switchButton.transform = CGAffineTransform(scaleX: 0.65, y: 0.65)
        self.tableView.dataSource = self
        self.searchHistoryTableView.dataSource = self
        self.searchTextField.delegate = self
        self.tableView.delegate = self
        self.searchHistoryTableView.delegate = self
        self.lottieLoading.animation = Animation.named("loadingAnim")
        self.lottieLoading.loopMode = .loop
        self.lottieLoading.play()
    }
    @IBAction func boardWrite(_ sender: Any) {
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "BoardWrite") as! BoardWriteViewController
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func goToRegionPick(_ sender: Any) {
        let nextVC = UIStoryboard(name: "RegionFilter", bundle: nil).instantiateViewController(withIdentifier: "RegionFilter") as! RegionFilterViewController
        nextVC.delegate = self
        self.present(nextVC, animated: true)
    }
    @IBAction func goToDatePick(_ sender: Any) {
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "BoardDatePicker") as! BoardDatePickerViewController
        nextVC.delegate = self
        self.present(nextVC, animated: true)
    }
    @IBAction func searchCancel(_ sender: Any) {
        setOriginViewAnim()
        self.searchTextField.endEditing(true)
        self.searchTextField.resignFirstResponder()
    }
    @IBAction func searchButtonClick(_ sender: Any) {
        searchBoard()
    }
    @IBAction func genderFilter(_ sender: UISwitch) {
        if sender.isOn {
            self.filterNum = 1
        }else {
            self.filterNum = 0
        }
        if self.searchTextField.text == "" {
            word = "0"
        }else {
            word = self.searchTextField.text ?? "0"
        }
        
        BoardService.shared.getBoardListRequest(code: regionCode, sdate: sDate, edate: eDate, word: word, filter: filterNum ) { data in
            guard let list = data else { return }
            self.boardList = list
            self.tableView.reloadData()
            
        }
    }
    
    func searchBoard() {
        if let word = self.searchTextField.text {
            insertQuery(item: word)
            selectQuery()
            self.word = word
            BoardService.shared.getBoardListRequest(code: regionCode, sdate: sDate, edate: eDate, word: word, filter: filterNum ) { data in
                if data == nil {
                    self.lottieLoading.stop()
                    self.lottieLoading.isHidden = true
                    self.simpleAlert(title: "Error", msg: "해당 데이터가 없습니다.")
                }
                guard let list = data else { return }
                self.boardList = list
                self.tableView.reloadData()
            }
            self.setOriginViewAnim()
            self.searchTextField.resignFirstResponder()
            self.lottieLoading.stop()
            self.lottieLoading.isHidden = true
        }
    }
}

extension BoardListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.tableView {
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return self.boardList.count
        } else {
            if section == 0 {
                return historyList.count
            } else {
                return 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BoardListCell", for: indexPath) as! BoardListTableViewCell
            cell.viewModel = boardList[indexPath.row]
            return cell
        } else {
            if indexPath.section == 0 {
                //히스토리
                 let cell = tableView.dequeueReusableCell(withIdentifier: "BoardSearchCell", for: indexPath) as! BoardSearchTableViewCell
                cell.data = self.historyList[indexPath.row]
                cell.deleteButton.addTarget(self, action: #selector(oneDeleteItem(sender:)), for: .touchUpInside)
                return cell
            } else {
                 let cell = tableView.dequeueReusableCell(withIdentifier: "BoardDeleteCell", for: indexPath) as! BoardDeleteTableCell
                cell.allDeleteButton.addTarget(self, action: #selector(allDeleteItem), for: .touchUpInside)
                return cell
                
            }
        }
    }
    
    @objc func allDeleteItem() {
        self.deleteAllQuery()
        selectQuery()
    }
    
    @objc func oneDeleteItem(sender: UIButton) {
        deleteQuery(id: "\(sender.tag)")
        selectQuery()
    }
}

extension BoardListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableView {
            let cell = tableView.cellForRow(at: indexPath) as! BoardListTableViewCell
            let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "BoardDetail") as! BoardDetailViewController
            nextVC.boardIdx = cell.boardIdx
            self.navigationController?.pushViewController(nextVC, animated: true)
        } else {
            if indexPath.section == 0 {
                let cell = tableView.cellForRow(at: indexPath) as! BoardSearchTableViewCell
                self.searchTextField.text = cell.data.item
                self.searchTextField.resignFirstResponder()
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
}

extension BoardListViewController: BoardPickDelegate {
    func getDate(sDate: String, eDate: String) {
        self.sDate = sDate
        self.eDate = eDate
        self.dateString = "\(sDate) ~ \(eDate)"
        self.dateButton.setTitle(dateString, for: .normal)
        self.lottieLoading.animation = Animation.named("loadingAnim")
        self.lottieLoading.loopMode = .loop
        self.lottieLoading.play()
        BoardService.shared.getBoardListRequest(code: regionCode, sdate: sDate, edate: eDate) { data in
            if data == nil {
                self.lottieLoading.stop()
                self.lottieLoading.isHidden = true
                self.simpleAlert(title: "Error", msg: "해당 데이터가 없습니다.")
            }
            guard let list = data else { return }
            self.boardList = list
            self.tableView.reloadData()
            self.lottieLoading.stop()
            self.lottieLoading.isHidden = true
        }
    }
    func getAllDate() {
        self.dateString = "날짜"
        self.dateButton.setTitle(dateString, for: .normal)
        self.lottieLoading.animation = Animation.named("loadingAnim")
        self.lottieLoading.loopMode = .loop
        self.lottieLoading.play()
        BoardService.shared.getBoardListRequest(code: regionCode) { data in
            if data == nil {
                self.lottieLoading.stop()
                self.lottieLoading.isHidden = true
                self.simpleAlert(title: "Error", msg: "해당 데이터가 없습니다.")
            }
            guard let list = data else { return }
            self.boardList = list
            self.tableView.reloadData()
            self.lottieLoading.stop()
            self.lottieLoading.isHidden = true
        
        }
    }
    func getRegion(regionCode: String, regionName: String) {
        self.regionCode = regionCode
        self.regionButton.setTitle(regionName, for: .normal)
        self.lottieLoading.animation = Animation.named("loadingAnim")
        self.lottieLoading.loopMode = .loop
        self.lottieLoading.play()
        UserInfo.shared.setDefaultRegion(regionCode: regionCode, regionName: regionName)
        BoardService.shared.getBoardListRequest(code: regionCode, sdate: sDate, edate: eDate, filter: filterNum) { data in
            if data == nil {
                self.simpleAlert(title: "Error", msg: "해당 데이터가 없습니다.")
            }
            guard let list = data else { return }
            self.boardList = list
            self.tableView.reloadData()
            self.lottieLoading.stop()
            self.lottieLoading.isHidden = true
        }
    }
}
