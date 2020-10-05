//
//  TransactionDetailTableViewController.swift
//  MoneyLoverClone
//
//  Created by Vu Xuan Cuong on 9/29/20.
//  Copyright © 2020 Vu Xuan Cuong. All rights reserved.
//

import UIKit
import Reusable
import SwiftDate

final class TransactionDetailTableViewController: UITableViewController {
    
    // MARK: - Outlet
    @IBOutlet private weak var categoryImageView: UIImageView!
    @IBOutlet private weak var categoryNameLabel: UILabel!
    @IBOutlet private weak var noteTextField: UITextField!
    @IBOutlet private weak var moneyLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var eventImageView: UIImageView!
    @IBOutlet private weak var eventTextField: UITextField!
    @IBOutlet private weak var deleteButton: UIButton!
    @IBOutlet private weak var fixButton: UIBarButtonItem!
    
    // MARK: - Properties
    let formatter = DateFormatter()
    let today = Date()
    var transaction = Transaction()
    var database: DBManager!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        setupView()
    }
    
    // MARK: - Views
    private func setupView() {
        let deleteButtonAttributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: UIColor.red
        ]
        let attributedString = NSAttributedString(string: "Xoá giao dịch", attributes: deleteButtonAttributes)
        deleteButton.setAttributedTitle(attributedString, for: .normal)
        navigationItem.title = "Chi tiết giao dịch"
        fixButton.do {
            $0.setTitleTextAttributes([.underlineStyle: 1], for: .normal)
        }
        let transactionTypeString = transaction.type
        guard let transactionType = TransactionType(rawValue: transactionTypeString) else { return }
        switch transactionType {
        case .expendsed:
            moneyLabel.textColor = .systemRed
        case .income:
            moneyLabel.textColor = .systemBlue
        }
    }
    
    // MARK: - Data
    private func setupData() {
        let locale = Locale(identifier: "vi")
        formatter.do {
            $0.dateStyle = .full
            $0.locale = locale
        }
        database = DBManager.shared
        let category = database.fetchCategory(from: transaction.categoryID)
        categoryImageView.image = UIImage(named: category.image)
        categoryNameLabel.text = category.name
        moneyLabel.text = transaction.money.convertToMoneyFormat()
        dateLabel.text = formatter.string(from: transaction.date)
        noteTextField.text = transaction.note
    }
    
    // MARK: - Action
    @IBAction func fixAction(_ sender: Any) {
        let transactionScreen = AddTransactionTableViewController.instantiate()
        let navigationController = UINavigationController(rootViewController: transactionScreen)
        present(navigationController, animated: true)
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        confirmDelete()
    }
    
    private func confirmDelete() {
        let alert = UIAlertController(title: nil, message: "Xoá giao dịch này?", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Xoá", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.database.deleteTransaction(self.transaction)
            self.navigationController?.popViewController(animated: true)
        }
        deleteAction.setValue(UIColor.red, forKey: "titleTextColor")
        let cancelAction = UIAlertAction(title: "Huỷ", style: .cancel, handler: nil)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
}

extension TransactionDetailTableViewController: StoryboardSceneBased {
    static var sceneStoryboard = Storyboard.transactionDetail
}
