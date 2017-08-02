//
//  ViewController.swift
//  EasyViewer
//
//  Created by Myron on 2017/7/4.
//  Copyright © 2017年 Myron. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        viewer.model = Viewer_Model()
    }

    @IBOutlet weak var viewer: Viewer!

}

