//
//  Viewer_protocol.swift
//  EasyViewer
//
//  Created by Myron on 2017/7/4.
//  Copyright © 2017年 Myron. All rights reserved.
//

import UIKit

// MARK: - Model

/** 数据模型协议 */
protocol Viewer_Model_Protocol: class {
    
    /** 当前位置 */
    var viewer_index: Int { get set }
    
    /** 获取数据 */
    func viewer(_ viewer: Viewer, data_at index: Int) -> Any?
    /** 视图移动，数据偏移 */
    func viewer(_ viewer: Viewer, move_to index: Int)
    /** 检查拖拽方向的合法性 */
    func viewer(_ viewer: Viewer, pan_check index: Int) -> Bool
    /** 删除当前视图 */
    func viewer(_ viewer: Viewer, delete index: Int)
}

// MARK: - Sub View

/** 视图浏览器内容协议 */
@objc protocol Viewer_Item_Protocol: Viewer_Item_Delegate_Protocol  {
    
    var image: UIImage? { get set }
    var frame: CGRect { get set }
    var content_size: CGSize { get }
    
    /** 更新数据 */
    @objc optional func viewer_item(viewer: Viewer, update_in offset: Int, index: Int, data: Any?)
}

/** 视图浏览器内容协议 */
@objc protocol Viewer_Item_Delegate_Protocol  {
    
    /** 点击事件 */
    @objc optional func viewer_item(viewer: Viewer, tap_action index: Int)
    /** 拖拽开始事件 */
    @objc optional func viewer_item(viewer: Viewer, pan_action_began index: Int)
    /** 拖拽结束事件 */
    @objc optional func viewer_item(viewer: Viewer, pan_action_ended index: Int)
    
    
}

// MARK: - Delegate

/** 视图浏览器代理方法 */
protocol Viewer_Delegate_Protocol: class {
    /** 点击事件 */
    func viewer(_ viewer: Viewer, tap_action index: Int)
    /** 拖拽开始事件 */
    func viewer(_ viewer: Viewer, pan_action_began index: Int)
    /** 拖拽结束事件 */
    func viewer(_ viewer: Viewer, pan_action_ended index: Int)
    
    /** 缩放事件 */
    func viewer(_ viewer: Viewer, pinch_action index: Int, scale: CGFloat)
    /** 缩放结束事件 */
    func viewer(_ viewer: Viewer, pinch_action_end index: Int, scale: CGFloat) -> Bool
    
    /** 删除事件 */
    func viewer(_ viewer: Viewer, delete_action index: Int)
    
}

