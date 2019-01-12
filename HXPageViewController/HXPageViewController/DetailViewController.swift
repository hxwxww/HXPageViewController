//
//  DetailViewController.swift
//  HXPageViewController
//
//  Created by HongXiangWen on 2019/1/7.
//  Copyright © 2019年 WHX. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    var text: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad: \(text)")
        
        let red = CGFloat(arc4random() % 255) / 255
        let green = CGFloat(arc4random() % 255) / 255
        let blue = CGFloat(arc4random() % 255) / 255
        view.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 1)
        
        titleLabel.text = text
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear: \(text)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear: \(text)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear: \(text)")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("viewDidDisappear: \(text)")
    }

    deinit {
        print("deinit: \(text)")
    }
    
}
