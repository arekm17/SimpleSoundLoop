//
//  PickerViewController.swift
//  SimpleSoundLoop
//
//  Created by Arek on 15.01.2019.
//  Copyright © 2019 Arek. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

protocol PickerViewDelegate: class {
    func pickerViewDidSelectItem(_ item: Metrum)
}

class PickerViewController: UIViewController {
    
    private let picker = UIPickerView(frame: .zero)

    weak var delegate: PickerViewDelegate?
    
    private static let items = Metrum.allCases
    
    init() {
        super.init(nibName: nil, bundle: nil)
        picker.delegate = self
        picker.dataSource = self
        
        picker.backgroundColor = UIColor.white
        view.addSubview(picker)
        
        picker.snp.makeConstraints { make in
            make.bottom.equalTo(bottomLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(300)
        }
        
    }
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        modalPresentationStyle = .currentContext
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

extension PickerViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return PickerViewController.items.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return PickerViewController.items[row].rawValue
    }
}

extension PickerViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        dismiss(animated: true, completion: nil)
        delegate?.pickerViewDidSelectItem(PickerViewController.items[row])
    }
}
