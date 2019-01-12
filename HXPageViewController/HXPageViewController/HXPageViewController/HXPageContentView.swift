//
//  HXPageContentView.swift
//  HXPageViewController
//
//  Created by HongXiangWen on 2019/1/7.
//  Copyright © 2019年 WHX. All rights reserved.
//

import UIKit

/// 设置contentOffset之后的回调
typealias HXPageContentViewDidSetContentOffsetCallback = (_ index: Int, _ animated: Bool) -> ()

class HXPageContentView: UIScrollView {

    // MARK: -  Properties
    
    /// 设置contentOffset之后的回调
    var didSetContentOffsetCallback: HXPageContentViewDidSetContentOffsetCallback?
    
    // MARK: -  init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        isPagingEnabled = true
        backgroundColor = .clear
        scrollsToTop = false
        bounces = false
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior =  .never
        }
    }

    // MARK: -  override
    
    override func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
        if let didSetContentOffsetCallback = didSetContentOffsetCallback {
            /// 手动设置contentOffset的动画
            let index = calculateIndex(of: contentOffset.x)
            didSetContentOffsetCallback(index, animated)
        } else {
            super.setContentOffset(contentOffset, animated: animated)
        }
    }
    
}

// MARK: -  Public Methods
extension HXPageContentView {
    
    /// 计算index
    ///
    /// - Parameter contentOffsetX: x偏移量
    /// - Returns: index
    func calculateIndex(of contentOffsetX: CGFloat = -1) -> Int {
        var offsetX = contentOffsetX
        if contentOffsetX == -1 {
            offsetX = contentOffset.x
        }
        var index = Int(offsetX / bounds.width)
        if index < 0 {
            index = 0
        }
        return index
    }
    
    /// 计算偏移
    ///
    /// - Parameter index: 位置
    /// - Returns: 偏移
    func calculateContentOffset(with index: Int) -> CGPoint {
        let width = bounds.width
        let maxWidth = contentSize.width
        var offsetX = CGFloat(index) * width
        if offsetX < 0 {
            offsetX = 0
        }
        if maxWidth > 0 && offsetX > maxWidth - width {
            offsetX = maxWidth - width
        }
        return CGPoint(x: offsetX, y: 0)
    }
    
    /// 计算某一页的frame
    ///
    /// - Parameter index: 位置
    /// - Returns: frame
    func calculateVisibleViewControllerFrame(with index: Int) -> CGRect {
        let offsetX = CGFloat(index) * bounds.width
        return CGRect(x: offsetX, y: 0, width: bounds.width, height: bounds.height)
    }
    
}
