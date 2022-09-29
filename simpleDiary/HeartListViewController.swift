//
//  HeartListViewController.swift
//  simpleDiary
//
//  Created by Yejin on 2022/09/20.
//

import UIKit

class HeartListViewController: UIViewController {
    @IBOutlet weak var heartTableView: UITableView!
    
    private var diaryList = [DiaryList]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        heartTableView.delegate = self
        heartTableView.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadHeartDiaryList()
    }
    
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    private func loadHeartDiaryList() {
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.object(forKey: "diaryList") as? [[String: Any]] else { return }
        self.diaryList = data.compactMap {
            guard let title = $0["title"] as? String else { return nil }
            guard let contents = $0["contents"] as? String else { return nil }
            guard let date = $0["date"] as? Date else { return nil }
            guard let heart = $0["heart"] as? Bool else { return nil }
            return DiaryList(title: title, contents: contents, date: date, heart: heart)
        }.filter({
            $0.heart == true
        }).sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })
        self.heartTableView.reloadData()
    }
}

extension HeartListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.diaryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HeartCell", for: indexPath)
        let diary = self.diaryList[indexPath.row]
        cell.textLabel?.text = diary.title
        cell.detailTextLabel?.text = self.dateToString(date: diary.date)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            diaryList.remove(at: indexPath.row)
            heartTableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            
        }
    }
}

extension HeartListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("클릭됨")
        guard let viewController = self.storyboard?.instantiateViewController(identifier: "detailDiaryViewController") as? DetailDiaryViewController else { return }
        let diary = self.diaryList[indexPath.row]
        viewController.diary = diary
        viewController.indexPath = indexPath
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
