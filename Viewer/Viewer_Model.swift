//
//  Viewer_Model.swift
//  EasyViewer
//
//  Created by Myron on 2017/7/4.
//  Copyright © 2017年 Myron. All rights reserved.
//

import UIKit

class Viewer_Model: Viewer_Model_Protocol {
    
    var images: [UIImage?] = []
    
    init() {
        for i in 1 ..< 9 {
            images.append(UIImage(named: "Esay Viewer \(i)"))
        }
    }
    
    /** 当前位置 */
    var viewer_index: Int = 0 {
        willSet {
            if newValue == -1 {
                print("NONONONO")
            }
        }
    }
    
    /** 获取数据 */
    func viewer(_ viewer: Viewer, data_at index: Int) -> Any? {
        if index > -1 && index < images.count {
            return images[index]
        }
        return nil
    }
    
    /** 视图移动，数据偏移 */
    func viewer(_ viewer: Viewer, move_to index: Int) {
        viewer_index = index
    }
    
    /** 检查拖拽方向的合法性 */
    func viewer(_ viewer: Viewer, pan_check index: Int) -> Bool {
        return index > -1 && index < images.count
    }

    /** 删除当前视图 */
    func viewer(_ viewer: Viewer, delete index: Int) {
        images.remove(at: index)
    }
}
