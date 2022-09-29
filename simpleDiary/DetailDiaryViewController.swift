//
//  detailDiaryViewController.swift
//  simpleDiary
//
//  Created by Yejin on 2022/09/19.
//

import UIKit

class DetailDiaryViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentsLabel: UITextView!
    var heartButton: UIBarButtonItem?
    
    var diary: DiaryList?
    var indexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
    }
    
    private func configureView() {
        guard let diary = self.diary else { return }
        self.titleLabel.text = diary.title
        self.dateLabel.text = dateToString(date: diary.date)
        self.contentsLabel.text = diary.contents
        self.heartButton = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(tapHeartButton))
        self.heartButton?.image = diary.heart ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
        self.heartButton?.tintColor = .systemPink
        self.navigationItem.rightBarButtonItem = self.heartButton
    }
    
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    @objc func editDiaryNotification(_ notification: Notification) {
        guard let diary = notification.object as? DiaryList else { return }
        guard let row = notification.userInfo?["indexPath.row"] as? Int else { return }
        self.diary = diary
        self.configureView()
    }
    
    @objc func tapHeartButton() {
        guard let heart = self.diary?.heart else { return }
        guard let indexPath = self.indexPath else { return }
        if heart {
            self.heartButton?.image = UIImage(systemName: "heart")
        } else {
            self.heartButton?.image = UIImage(systemName: "heart.fill")
        }
        self.diary?.heart = !heart //트루이면 펄스가 대입, 펄스이면 트루가 대입
        NotificationCenter.default.post(
            name: NSNotification.Name("heartDiary"),
            object: [
                "heart": self.diary?.heart ?? false,
                "indexPath": indexPath
            ],
            userInfo: nil
        )
        //self.delegate?.didSelectHeart(indexPath: indexPath, heart: self.diary?.heart ?? false)
    }
    
    //수정창에 어떤 정보를 수정할건지에 대한 데이터 전달을 위한 코드
    @IBAction func editBtn(_ sender: Any) {
        guard let addDiaryViewController = self.storyboard?.instantiateViewController(identifier: "AddDiaryViewController") as? AddDiaryViewController else { return }
        guard let indexPath = self.indexPath else { return }
        guard let diary = self.diary else { return }
        addDiaryViewController.editDiary = .edit(indexPath, diary)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(editDiaryNotification(_:)),
            name: NSNotification.Name("editDiary"),
            object: nil
        )
        self.navigationController?.pushViewController(addDiaryViewController, animated: true)
        
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
