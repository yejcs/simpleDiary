//
//  AddDiaryViewController.swift
//  simpleDiary
//
//  Created by Yejin on 2022/09/16.
//

//MARK: 텍스트뷰 placeholder 넣기
//MARK: 데이트 텍스트필드의 디폴트 날짜를 오늘 날짜로 설정하기.

import UIKit

//수정창에 어떤 정보를 수정할건지에 대한 데이터 전달을 위한 코드
enum EditDiary {
    case new
    case edit(IndexPath, DiaryList)
}

protocol AddDiaryViewDelegate: AnyObject {
    func didSelectOK(diary: DiaryList)
}

class AddDiaryViewController: UIViewController {

    @IBOutlet weak var titleTxt: UITextField!
    @IBOutlet weak var dateTxt: UITextField!
    @IBOutlet weak var contentTxt: UITextView!
    @IBOutlet weak var OKBtn: UIButton!
    
    private let datePicker = UIDatePicker()
    private var diaryDate: Date?
    weak var delegate: AddDiaryViewDelegate?
    var editDiary: EditDiary = .new//수정창에 어떤 정보를 수정할건지에 대한 데이터 전달을 위한 코드
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textViewConfigure()
        self.datePickerConfigure()
        self.OKBtnConfigure()
        self.OKBtn.isEnabled = false
        self.editConfigure()
    }
    
    private func editConfigure() {
        switch self.editDiary {
        case let .edit(_, diary):
            self.titleTxt.text = diary.title
            self.contentTxt.text = diary.contents
            self.dateTxt.text = dateToString(date: diary.date)
            self.diaryDate = diary.date
        default:
            break
        }
    }
    
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    private func textViewConfigure() {
        let borderColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
        self.contentTxt.layer.borderColor = borderColor.cgColor
        self.contentTxt.layer.borderWidth = 0.5
        self.dateTxt.layer.cornerRadius = 6.0
    }
    
    private func datePickerConfigure() {
        self.datePicker.datePickerMode = .date
        self.datePicker.preferredDatePickerStyle = .wheels
        self.datePicker.addTarget(self, action: #selector(datePickerValueDidChange(_:)), for: .valueChanged)
        self.dateTxt.inputView = self.datePicker //dateTxt 클릭 시 데이트피커 등장!
    }
    
    private func OKBtnConfigure() {
        self.contentTxt.delegate = self
        self.titleTxt.addTarget(self, action: #selector(titleTxtDidChange(_:)), for: .editingChanged)
        self.dateTxt.addTarget(self, action: #selector(dateTxtDidChange(_:)), for: .editingChanged)
    }
    
    @IBAction func OKBtn(_ sender: Any) {
        guard let title = self.titleTxt.text else { return }
        guard let date = self.diaryDate else { return }
        guard let content = self.contentTxt.text else { return }
        let diary = DiaryList(title: title, contents: content, date: date, heart: false)
        
        switch self.editDiary {
        case .new:
            self.delegate?.didSelectOK(diary: diary)
            
        case let .edit(indexPath, _):
            NotificationCenter.default.post(
                name: NSNotification.Name("editDiary"),
                object: diary,
                userInfo: [
                    "indexPath.row": indexPath.row
                ]
            )
        }
        
        //self.delegate?.didSelectOK(diary: diary)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func datePickerValueDidChange(_ datePicker: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일 (EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        self.diaryDate = datePicker.date
        self.dateTxt.text = formatter.string(from: datePicker.date) //dateTxt에 날짜 나타냄
        self.dateTxt.sendActions(for: .editingChanged)
    }
    
    @objc private func titleTxtDidChange(_ textField: UITextField) {
        self.validateInputField()
    }
    @objc private func dateTxtDidChange(_ textField: UITextField) {
        self.validateInputField()
    }
    
    //빈공간 클릭 시 터치바 사라짐
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func validateInputField() {
        self.OKBtn.isEnabled = !(self.titleTxt.text?.isEmpty ?? true) && !(self.dateTxt.text?.isEmpty ?? true) && !self.contentTxt.text.isEmpty
    }

}

extension AddDiaryViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.validateInputField()
    }
}
