//
//  MetrumButton.swift
//  SimpleSoundLoop
//
//  Created by Arek on 15.01.2019.
//  Copyright © 2019 Arek. All rights reserved.
//

import Foundation
import UIKit

class MetrumButton: UIButton {

    public var metrum: Metrum = .none {
        didSet {
            setTitle(metrum.rawValue, for: .normal) //move to setter
        }
    }

    private let picker = PickerViewController()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setTitle(Metrum.none.rawValue, for: .normal)
        picker.delegate = self
        addTarget(self, action: #selector(showPicker), for: .touchUpInside)
    }
    
}

extension MetrumButton {
    @objc func showPicker() {
        if let vc = UIApplication.shared.keyWindow?.rootViewController {
            vc.present(picker, animated: true)
        }
    }
}

extension MetrumButton: PickerViewDelegate {
    func pickerViewDidSelectItem(_ item: Metrum) {
        metrum = item
    }
}
