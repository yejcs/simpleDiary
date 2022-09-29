//
//  ViewController.swift
//  simpleDiary
//
//  Created by Yejin on 2022/09/15.
//
// 날짜순으로 정렬 기능 OK!
// 앱이 꺼져도 데이터 유지 OK!
//MARK: 하트
// 일기 삭제OK 및 수정OK 기능
// 일기 클릭 시 상세뷰로 내용 표시 OK

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var diaryListTableView: UITableView!
    var diaryList = [DiaryList]() {
        didSet {
            self.saveDiary()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        diaryListTableView.dataSource = self
        diaryListTableView.delegate = self
        self.loadDiary()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(editDiaryNotification(_:)),
            name: NSNotification.Name("editDiary"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(heartDiaryNotification(_:)),
            name: NSNotification.Name("heartDiary"),
            object: nil
        )
    }
    
    @objc func editDiaryNotification(_ notification: Notification) {
        guard let diary = notification.object as? DiaryList else { return }
        guard let row = notification.userInfo?["indexPath.row"] as? Int else { return }
        self.diaryList[row] = diary
        self.diaryList = self.diaryList.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })
        self.diaryListTableView.reloadData()
    }
    
    @objc func heartDiaryNotification(_ notification: Notification){
        guard let heartDiary = notification.object as? [String: Any] else { return }
        guard let heart = heartDiary["heart"] as? Bool else { return }
        guard let indexPath = heartDiary["indexPath"] as? IndexPath else { return }
        self.diaryList[indexPath.row].heart = heart
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addDiaryViewController = segue.destination as? AddDiaryViewController {
            addDiaryViewController.delegate = self
        }
    }
    
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    
    //userDefaults를 이용해 앱이 종료돼도 데이터가 저장되도록!
    //MARK: 사실 그냥 따라한거라 이해는 안가서 분석이 더 필요함!
    func saveDiary() {
        let data = self.diaryList.map {
            [
                "title": $0.title,
                "contents": $0.contents,
                "date": $0.date,
                "heart": $0.heart
            ]
        }
        let userDefaults = UserDefaults.standard
        userDefaults.set(data, forKey: "diaryList")
    }
    func loadDiary() {
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.object(forKey: "diaryList") as? [[String: Any]] else { return }
        self.diaryList = data.compactMap {
            guard let title = $0["title"] as? String else { return nil }
            guard let contents = $0["contents"] as? String else { return nil }
            guard let date = $0["date"] as? Date else { return nil }
            guard let heart = $0["heart"] as? Bool else { return nil }
            return DiaryList(title: title, contents: contents, date: date, heart: heart)
        }
        //날짜순 정렬
//        self.diaryList = self.diaryList.sorted(by: {
//            $0.date.compare($1.date) == .orderedDescending
//        })
    }
}

extension ViewController: AddDiaryViewDelegate {
    func didSelectOK(diary: DiaryList) {
        self.diaryList.append(diary)
        //일기를 배열에 추가할 때 날짜순으로
        self.diaryList = self.diaryList.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })
        self.diaryListTableView.reloadData()
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.diaryList.count
    }
    
    
    //MARK: 셀 폰트사이즈조정
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) //?? UITableViewCell.init(style: .subtitle, reuseIdentifier: "Cell")
        let diary = self.diaryList[indexPath.row]
        let date = dateToString(date: diary.date)
        cell.textLabel?.text = diary.title
        cell.detailTextLabel?.text = date
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            diaryList.remove(at: indexPath.row)
            diaryListTableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "삭제"
    }
}

extension ViewController: UITableViewDelegate {
    //클릭 이벤트 발생을 위한 함수
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewController = self.storyboard?.instantiateViewController(identifier: "detailDiaryViewController") as? DetailDiaryViewController else { return }
        let diary = self.diaryList[indexPath.row]
        viewController.diary = diary
        viewController.indexPath = indexPath
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

