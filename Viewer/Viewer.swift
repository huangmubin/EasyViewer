//
//  Viewer.swift
//  EasyViewer
//
//  Created by Myron on 2017/7/4.
//  Copyright © 2017年 Myron. All rights reserved.
//

import UIKit

/** 视图浏览器 */
class Viewer: UIView {
    
    // MARK: - Data
    
    /** 数据 */
    var model: Viewer_Model_Protocol? {
        didSet {
            views_reset_data()
        }
    }
    
    /** */
    weak var delegate: Viewer_Delegate_Protocol?
    
    /** 最大缩放倍数 */
    var scale_multiple: CGFloat = 3
    /** 缩放高宽比例 */
    var scale_w_to_h: CGFloat = 0

    // MARK: - Init
    
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        deploy()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        deploy()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        deploy()
    }
    
    private func deploy() {
        scale_w_to_h = self.bounds.width / self.bounds.height
        
        views_deploy()
        views_reset_frame()
        views_reset_data()
        gesture_deploy()
    }
    
    // MARK: - Frame
    
    override var frame: CGRect {
        didSet {
            scale_w_to_h = self.bounds.width / self.bounds.height
            UIView.animate(withDuration: 0.25, animations: {
                self.views_reset_frame()
            })
        }
    }
    
    override var bounds: CGRect {
        didSet {
            scale_w_to_h = self.bounds.width / self.bounds.height
            UIView.animate(withDuration: 0.25, animations: {
                self.views_reset_frame()
            })
        }
    }
    
    // MARK: - SubViews
    
    /** 内容视图 */
    var view_l: Viewer_Item_Protocol = Viewer_Item()
    var view_r: Viewer_Item_Protocol = Viewer_Item()
    var view_c: Viewer_Item_Protocol = Viewer_Item()
    
    /** 配置所有子视图 */
    func views_deploy() {
        for view in [view_l, view_c, view_r] {
            addSubview(view as! UIView)
            (view as? UIImageView)?.contentMode = .scaleAspectFit
        }
    }
    
    /** 重置中心视图 */
    func view_reset_center(_ view: Viewer_Item_Protocol) {
        (view_c as? UIView)?.removeFromSuperview()
        view.image = view_c.image
        view.frame = view_c.frame
        (view as? UIImageView)?.contentMode = .scaleAspectFit
        addSubview(view as! UIView)
        view_c = view
    }
    
    /** 重置左边视图 */
    func view_reset_left(_ view: Viewer_Item_Protocol) {
        (view_l as? UIView)?.removeFromSuperview()
        view.image = view_l.image
        view.frame = view_l.frame
        (view as? UIImageView)?.contentMode = .scaleAspectFit
        addSubview(view as! UIView)
        view_l = view
    }
    
    /** 重置右边视图 */
    func view_reset_right(_ view: Viewer_Item_Protocol) {
        (view_r as? UIView)?.removeFromSuperview()
        view.image = view_r.image
        view.frame = view_r.frame
        (view as? UIImageView)?.contentMode = .scaleAspectFit
        addSubview(view as! UIView)
        view_r = view
    }
    
    /** 重置子视图位置，尺寸 */
    func views_reset_frame() {
        view_l.frame = CGRect(
            x: -self.bounds.width - 10,
            y: 0,
            width: self.bounds.width,
            height: self.bounds.height
        )
        view_c.frame = CGRect(
            x: 0,
            y: 0,
            width: self.bounds.width,
            height: self.bounds.height
        )
        view_r.frame = CGRect(
            x: self.bounds.width + 10,
            y: 0,
            width: self.bounds.width,
            height: self.bounds.height
        )
    }
    
    /** 更新数据 */
    func views_reset_data() {
        func update(view: Viewer_Item_Protocol, index: Int, offset: Int, data: Any?) {
            if let image = data as? UIImage {
                view.image = image
            }
            view.viewer_item?(
                viewer: self,
                update_in: offset,
                index: index + offset,
                data: data
            )
        }
        
        if let index = model?.viewer_index {
            update(
                view: view_l,
                index: index,
                offset: -1,
                data: model?.viewer(self, data_at: index - 1)
            )
            update(
                view: view_c,
                index: index,
                offset: 0,
                data: model?.viewer(self, data_at: index)
            )
            update(
                view: view_r,
                index: index,
                offset: 1,
                data: model?.viewer(self, data_at: index + 1)
            )
        }
    }
    
    /** 调整尺寸 */
    func views_adjust_frame() {
        if view_c.frame.width <= self.bounds.width {
            views_reset_frame()
        }
        else if view_c.content_size != CGSize.zero {
            let size = view_c.content_size
            var result = view_c.frame
            if result.width > self.bounds.width * scale_multiple {
                let width = self.bounds.width * scale_multiple
                let height = self.bounds.height * scale_multiple
                result.origin.x += (result.size.width - width) / 2
                result.origin.y += (result.size.height - height) / 2
                result.size.width = width
                result.size.height = height
            }
            // Image is width bigger.
            if size.width / size.height > view_c.frame.width / view_c.frame.height {
                if result.origin.x > 0 {
                    result.origin.x = 0
                }
                else if result.origin.x + result.width < self.bounds.width {
                    result.origin.x = self.bounds.width - result.width
                }
                
                let image_scale = size.width / size.height
                let image_minY_origin = (self.bounds.height - self.bounds.width / image_scale) / 2
                let image_minY_now    = (result.height - result.width / image_scale) / 2
                let space_y = image_minY_now - image_minY_origin
                
                if result.origin.y > -space_y {
                    result.origin.y = -space_y
                }
                else if result.origin.y + result.height - space_y < self.bounds.height {
                    result.origin.y = self.bounds.height - result.height + space_y
                }
            }
            else {
                if result.origin.y > 0 {
                    result.origin.y = 0
                }
                else if result.origin.y + result.height < self.bounds.height {
                    result.origin.y = self.bounds.height - result.height
                }
                
                let image_scale = size.width / size.height
                let image_width = result.height * image_scale
                let space_offset = (image_width >= self.bounds.width) ? 0 : ((self.bounds.width - image_width) / 2)
                let space_x    = (result.width - result.height * image_scale) / 2 - space_offset
                
                if result.origin.x > -space_x {
                    result.origin.x = -space_x
                }
                else if result.origin.x + result.width - space_x < self.bounds.width {
                    result.origin.x = self.bounds.width - result.width + space_x
                }
            }
            view_c.frame = result
            view_l.frame.origin.x = -self.bounds.width - 10
            view_r.frame.origin.x = self.bounds.width + 10
        }
        else {
            views_reset_data()
        }
    }
    
    
    // MARK: - Gesture
    
    /** 拖拽 */
    var gesture_pan: UIPanGestureRecognizer!
    /** 缩放 */
    var gesture_pin: UIPinchGestureRecognizer!
    /** 单击 */
    var gesture_tap: UITapGestureRecognizer!
    /** 双击 */
    var gesture_dou: UITapGestureRecognizer!
    
    /** 拖拽初始点 */
    var gesture_pan_point = CGPoint.zero
    /**  */
    var gesture_pan_space_offset: CGFloat = 0
    /**  */
    var gesture_pan_limit = CGPoint.zero
    
    /** 是否可以往前拖拽 */
    var gesture_pan_front: Bool = true
    /** 是否可以往后拖拽 */
    var gesture_pan_back: Bool = true
    
    /** */
    func gesture_pan_action(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            // 初始化数据
            gesture_pan_point = view_c.frame.origin
            gesture_pan_space_offset = 0
            gesture_pan_limit.x = 0
            gesture_pan_limit.y = self.bounds.height - view_c.frame.height
            
            // 更新位置
            if view_c.content_size != CGSize.zero {
                let size = view_c.content_size
                if size.width / size.height < view_c.frame.width / view_c.frame.height {
                    let image_scale = size.width / size.height
                    gesture_pan_space_offset = (view_c.frame.width - view_c.frame.height * image_scale) / 2
                    
                    let image_width = view_c.frame.height * image_scale
                    if image_width < self.bounds.width {
                        gesture_pan_space_offset -= ((self.bounds.width - image_width) / 2)
                    }
                }
                else {
                    let image_scale = size.width / size.height
                    let image_minY_origin = (self.bounds.height - self.bounds.width / image_scale) / 2
                    let image_minY_now    = (view_c.frame.height - view_c.frame.width / image_scale) / 2
                    let space_y = image_minY_now - image_minY_origin
                    gesture_pan_limit.x = -space_y
                    gesture_pan_limit.y = self.bounds.height - view_c.frame.height + space_y
                }
            }
            
            // 事件回调
            view_c.viewer_item?(
                viewer: self,
                pan_action_began: (model?.viewer_index ?? -1)
            )
            
            // 方向
            if let index = model?.viewer_index {
                gesture_pan_front = model?.viewer(
                    self,
                    pan_check: index - 1
                ) ?? false
                gesture_pan_back  = model?.viewer(
                    self,
                    pan_check: index + 1
                ) ?? false
            }
            else {
                gesture_pan_front = false
                gesture_pan_back  = false
            }
            
            delegate?.viewer(
                self,
                pan_action_began: model?.viewer_index ?? 0
            )
        case .changed:
            let translation = sender.translation(in: self)
            
            //
            var result_y = gesture_pan_point.y + translation.y
            if result_y > gesture_pan_limit.x {
                result_y = gesture_pan_limit.x + sqrt(result_y - gesture_pan_limit.x)
            }
            else if result_y < gesture_pan_limit.y {
                result_y = gesture_pan_limit.y - sqrt(gesture_pan_limit.y - result_y)
            }
            
            //
            var move_x = gesture_pan_point.x + translation.x
            if move_x > 0 {
                if !gesture_pan_front {
                    move_x = sqrt(move_x)
                }
            }
            else if move_x + view_c.frame.width < bounds.width {
                if !gesture_pan_back {
                    var offset_x = bounds.width - move_x - view_c.frame.width
                    offset_x = sqrt(offset_x)
                    move_x = bounds.width - view_c.frame.width - offset_x
                }
            }
            
            //
            view_c.frame.origin = CGPoint(
                x: move_x,
                y: result_y
            )
            
            view_l.frame.origin.x = (
                view_c.frame.origin.x
                    - self.bounds.width
                    - 10
                    + gesture_pan_space_offset
            )
            view_r.frame.origin.x = (
                view_c.frame.origin.x
                    + view_c.frame.width
                    + 10
                    - gesture_pan_space_offset
            )
        case .ended:
            if (view_l.frame.maxX > self.bounds.width / 2
                || sender.velocity(in: self).x > 100)
                && gesture_pan_front {
                //print("gesture_pan_front = \(gesture_pan_front); \(String(describing: model?.viewer_index))")
                self.gesture_pan.isEnabled = false
                UIView.animate(withDuration: 0.25, animations: {
                    self.view_l.frame.origin.x = 0
                    self.view_r.frame.origin.x = self.bounds.width * 2 + 20
                    self.view_c.frame = CGRect(
                        x: self.bounds.width + 10,
                        y: 0,
                        width: self.bounds.width,
                        height: self.bounds.height
                    )
                }, completion: { _ in
                    //print("gesture_pan_front completion = \(self.gesture_pan_front); \(String(describing: self.model?.viewer_index))")
                    self.model?.viewer(
                        self,
                        move_to: self.model!.viewer_index - 1
                    )
                    self.views_reset_frame()
                    self.views_reset_data()
                    
                    self.delegate?.viewer(
                        self,
                        pan_action_ended: self.model?.viewer_index ?? 0
                    )
                    
                    self.gesture_pan.isEnabled = true
                })
            }
            else if view_r.frame.minX < self.bounds.width / 2
                || sender.velocity(in: self).x < -100
                && gesture_pan_back {
                self.gesture_pan.isEnabled = false
                UIView.animate(withDuration: 0.25, animations: {
                    self.view_l.frame.origin.x = -self.bounds.width * 2 - 20
                    self.view_r.frame.origin.x = 0
                    self.view_c.frame = CGRect(
                        x: -self.bounds.width - 10,
                        y: 0,
                        width: self.bounds.width,
                        height: self.bounds.height
                    )
                }, completion: { _ in
                    self.model?.viewer(
                        self,
                        move_to: self.model!.viewer_index + 1
                    )
                    self.views_reset_frame()
                    self.views_reset_data()
                    
                    self.delegate?.viewer(
                        self,
                        pan_action_ended: self.model?.viewer_index ?? 0
                    )
                    
                    self.gesture_pan.isEnabled = true
                })
            }
            else {
                self.gesture_pan.isEnabled = false
                UIView.animate(withDuration: 0.25, animations: {
                    self.views_adjust_frame()
                }, completion: { _ in
                    self.delegate?.viewer(
                        self,
                        pan_action_ended: self.model?.viewer_index ?? 0
                    )
                    
                    self.gesture_pan.isEnabled = true
                })
            }
            
            // 回调
            view_c.viewer_item?(
                viewer: self,
                pan_action_ended: (model?.viewer_index ?? -1)
            )
        default:
            break
        }
    }
    
    // 缩放手势
    var gesture_pinch_size = CGSize.zero
    var gesture_pinch_point = CGPoint.zero
    func gesture_pinch_action(_ sender: UIPinchGestureRecognizer) {
        switch sender.state {
        case .began:
            let point1 = sender.location(ofTouch: 0, in: view_c as? UIView)
            let point2 = sender.location(ofTouch: 1, in: view_c as? UIView)
            gesture_pinch_point.x = ((point1.x + point2.x) / 2) / view_c.frame.width
            gesture_pinch_point.y = ((point1.y + point2.y) / 2) / view_c.frame.height
            gesture_pinch_size = view_c.frame.size
        case .changed:
            view_c.frame.size.width  = gesture_pinch_size.width  * sender.scale
            view_c.frame.size.height = gesture_pinch_size.height * sender.scale
            if sender.numberOfTouches >= 2 {
                let point1 = sender.location(ofTouch: 0, in: self)
                let point2 = sender.location(ofTouch: 1, in: self)
                let touch_center = CGPoint(
                    x: (point1.x + point2.x) / 2,
                    y: (point1.y + point2.y) / 2
                )
                let view_center = CGPoint(
                    x: gesture_pinch_point.x * view_c.frame.width,
                    y: gesture_pinch_point.y * view_c.frame.height
                )
                view_c.frame.origin.x = touch_center.x - view_center.x
                view_c.frame.origin.y = touch_center.y - view_center.y
            }
            
            delegate?.viewer(
                self,
                pinch_action: model?.viewer_index ?? 0,
                scale: view_c.frame.width / self.bounds.width
            )
        case .ended:
            if delegate?.viewer(
                    self,
                    pinch_action_end: model?.viewer_index ?? 0,
                    scale: view_c.frame.width / self.bounds.width
                ) != false {
                UIView.animate(withDuration: 0.25, animations: {
                    self.views_adjust_frame()
                })
            }
        default:
            break
        }
        
    }
    
    /** 单击 */
    func gesture_tap_action(_ sender: UITapGestureRecognizer) {
        let index = model?.viewer_index ?? -1
        view_c.viewer_item?(
            viewer: self,
            tap_action: index
        )
        delegate?.viewer(
            self,
            tap_action: index
        )
    }
    
    /** 双击 */
    func gesture_double_action(_ sender: UITapGestureRecognizer) {
        if view_c.frame.width > self.bounds.width {
            UIView.animate(withDuration: 0.25, animations: {
                self.view_c.frame = self.bounds
            })
        }
        else {
            var frame = CGRect(
                x: 0, y: 0,
                width: self.bounds.width * scale_multiple,
                height: self.bounds.height * scale_multiple
            )
            let touch = sender.location(in: view_c as? UIView)
            let x_scale = touch.x / view_c.frame.width
            let y_scale = touch.y / view_c.frame.height
            frame.origin.x = touch.x - frame.width * x_scale
            frame.origin.y = touch.y - frame.height * y_scale
            UIView.animate(withDuration: 0.25, animations: {
                self.view_c.frame = frame
            }, completion: { _ in
                UIView.animate(withDuration: 0.25, animations: {
                    self.views_adjust_frame()
                })
            })
        }
    }
    
    // 手势配置
    func gesture_deploy() {
        gesture_pan = UIPanGestureRecognizer(target: self, action: #selector(gesture_pan_action(_:)))
        gesture_pin = UIPinchGestureRecognizer(target: self, action: #selector(gesture_pinch_action(_:)))
        gesture_tap = UITapGestureRecognizer(target: self, action: #selector(gesture_tap_action(_:)))
        gesture_dou = UITapGestureRecognizer(target: self, action: #selector(gesture_double_action(_:)))
        
        gesture_dou.numberOfTapsRequired = 2
        gesture_tap.require(toFail: gesture_dou)
        
        self.addGestureRecognizer(gesture_pan)
        self.addGestureRecognizer(gesture_pin)
        self.addGestureRecognizer(gesture_tap)
        self.addGestureRecognizer(gesture_dou)
    }
    
    // MARK: - Action
    
    /** 删除当前视图 */
    func delete_current_item() {
        if let index = self.model?.viewer_index, let view = view_c as? UIView {
            UIView.animate(withDuration: 1, animations: {
                view.alpha = 0
            }, completion: { _ in
                self.model?.viewer(self, delete: index)
                self.delegate?.viewer(self, delete_action: index)
                self.views_reset_data()
                view.alpha = 1
            })
        }
    }
    
}
