//
//  EstimateViewController.swift
//  With
//
//  Created by anhyunjun on 27/12/2019.
//  Copyright © 2019 ns. All rights reserved.
//

import UIKit

class EstimateViewController: UIViewController {
    
    @IBOutlet weak var funBtn: UIButton!
    @IBOutlet weak var sosoBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func pressfunBtn(_ sender: UIButton) { sender.isSelected = !sender.isSelected
        if sender.isSelected {
            funBtn.layer.cornerRadius = 10
            sender.backgroundColor = UIColor.init(red: 49/255, green: 26/255, blue: 128/255, alpha: 1)
              guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "EstimateWiTH") else {return}
                      nextVC.modalPresentationStyle = .overFullScreen
            self.present(nextVC, animated: true)
        }else {
            funBtn.layer.cornerRadius = 10
            sender.backgroundColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.3)
       guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "EstimateWiTH") else {return}
                 nextVC.modalPresentationStyle = .overFullScreen
            self.present(nextVC, animated: true)
        }}
    
    
    @IBAction func presssosoBtn(_ sender: UIButton) { sender.isSelected = !sender.isSelected
        if sender.isSelected {
            sosoBtn.layer.cornerRadius = 10
            sender.backgroundColor = UIColor.init(red: 49/255, green: 26/255, blue: 128/255, alpha: 1)
            guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "EstimateWiTH") else {return}
                            nextVC.modalPresentationStyle = .overFullScreen
            self.present(nextVC, animated: true)
        }else {
            funBtn.layer.cornerRadius = 10
            sender.backgroundColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.3)
            guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "EstimateWiTH") else {return}
                            nextVC.modalPresentationStyle = .overFullScreen
            self.present(nextVC, animated: true)
        }
    }
}

