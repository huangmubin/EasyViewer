//
//  Viewer_Item.swift
//  EasyViewer
//
//  Created by Myron on 2017/7/4.
//  Copyright © 2017年 Myron. All rights reserved.
//

import UIKit

class Viewer_Item: UIImageView, Viewer_Item_Protocol {
    
    var content_size: CGSize {
        return image?.size ?? CGSize.zero
    }
    
    /** 更新数据 */
    func viewer_item(viewer: Viewer, update_in offset: Int, index: Int, data: Any?) {
        if data == nil {
            image = nil
        }
    }
    
    /** 点击事件 */
    func viewer_item(viewer: Viewer, tap_action index: Int) {
        
    }
    
    /** 拖拽开始事件 */
    func viewer_item(viewer: Viewer, pan_action_began index: Int) {
        
    }
    
    /** 拖拽结束事件 */
    func viewer_item(viewer: Viewer, pan_action_ended index: Int) {
        
    }

}
