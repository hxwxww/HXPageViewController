//
//  HXPageTabBar.swift
//  HXPageViewController
//
//  Created by HongXiangWen on 2019/1/8.
//  Copyright © 2019年 WHX. All rights reserved.
//

import UIKit

/// 自适应标记
let HXPageViewAutomaticDimension: CGFloat = -1

@objc enum HXPageTabBarItemTransitionAnimationType: Int {
    /// 无动画
    case none
    /// 平滑的
    case smoothness
}

// MARK: -  行为代理
@objc protocol HXPageTabBarDelegate: class {
    
    /// 选中index的回调
    ///
    /// - Parameters:
    ///   - pageTabBar: pageTabBar
    ///   - index: 当前index
    @objc optional func pageTabBar(_ pageTabBar: HXPageTabBar, didSelectedItemAt index: Int)

    /// 正在滚动的回调
    ///
    /// - Parameters:
    ///   - pageTabBar: pageTabBar
    ///   - fromIndex: fromIndex
    ///   - toIndex: toIndex
    ///   - percent: 进度
    @objc optional func pageTabBar(_ pageTabBar: HXPageTabBar, didScrollItem fromIndex: Int, toIndex: Int, percent: CGFloat)
    
}

// MARK: -  数据源代理
@objc protocol HXPageTabBarDataSource: class {

    /// 选项数目
    ///
    /// - Parameter pageTabBar: pageContainer
    /// - Returns: 选项数目
    func numberOfItems(in pageTabBar: HXPageTabBar) -> Int
    
    /// index位置的item标题
    ///
    /// - Parameters:
    ///   - pageTabBar: pageContainer
    ///   - index: 位置
    /// - Returns: index位置的item标题
    func pageTabBar(_ pageTabBar: HXPageTabBar, titleForItemAt index: Int) -> String
    
    /// 默认选中位置，默认为0
    ///
    /// - Parameter pageTabBar: pageTabBar
    /// - Returns: 默认选中位置
    @objc optional func defaultSelectedIndex(in pageTabBar: HXPageTabBar) -> Int
    
    /// index位置的item宽度，默认为自适应
    ///
    /// - Parameters:
    ///   - pageTabBar: pageContainer
    ///   - index: 位置
    /// - Returns: index位置的item宽度
    @objc optional func pageTabBar(_ pageTabBar: HXPageTabBar, widthForItemAt index: Int) -> CGFloat
    
    /// 默认字体，默认为15号系统字体
    ///
    /// - Parameter pageTabBar: pageTabBar
    /// - Returns: 默认字体
    @objc optional func titleFontForItem(in pageTabBar: HXPageTabBar) -> UIFont
    
    /// 高亮字体，默认为15号系统字体
    ///
    /// - Parameter pageTabBar: pageTabBar
    /// - Returns: 高亮字体
    @objc optional func titleHighlightedFontForItem(in pageTabBar: HXPageTabBar) -> UIFont
    
    /// 默认字体颜色，默认为浅灰色
    ///
    /// - Parameter pageTabBar: pageTabBar
    /// - Returns: 默认字体颜色
    @objc optional func titleColorForItem(in pageTabBar: HXPageTabBar) -> UIColor
    
    /// 高亮字体颜色，默认为黑色
    ///
    /// - Parameter pageTabBar: pageTabBar
    /// - Returns: 高亮字体颜色
    @objc optional func titleHighlightedColorForItem(in pageTabBar: HXPageTabBar) -> UIColor

    /// item之间的间距，默认为10
    ///
    /// - Parameter pageTabBar: pageTabBar
    /// - Returns: item之间的间距
    @objc optional func spacingForItem(in pageTabBar: HXPageTabBar) -> CGFloat
    
    /// 是否开启当item总宽度小于总的宽度时居中显示所有item，并重新计算item之间的间距，默认开启
    ///
    /// - Parameter pageTabBar: pageTabBar
    /// - Returns: 是否开启
    @objc optional func relayoutWhenWidthNotEnough(in pageTabBar: HXPageTabBar) -> Bool
    
    /// 是否需要指示器，默认为true
    ///
    /// - Parameter pageTabBar: pageTabBar
    /// - Returns: 是否需要指示器
    @objc optional func needsIndicatorView(in pageTabBar: HXPageTabBar) -> Bool

    /// 指示器的颜色，默认为选中字体颜色
    ///
    /// - Parameter pageTabBar: pageTabBar
    /// - Returns: 指示器的颜色
    @objc optional func colorForIndicatorView(in pageTabBar: HXPageTabBar) -> UIColor
    
    /// 指示器的高度，默认为3
    ///
    /// - Parameter pageTabBar: pageTabBar
    /// - Returns: 指示器的高度
    @objc optional func heightForIndicatorView(in pageTabBar: HXPageTabBar) -> CGFloat
    
    /// 指示器距离底部的位置，默认为5
    ///
    /// - Parameter pageTabBar: pageTabBar
    /// - Returns: 指示器距离底部的位置
    @objc optional func bottomForIndicatorView(in pageTabBar: HXPageTabBar) -> CGFloat
    
    /// 指示器的宽度，默认自适应
    ///
    /// - Parameters:
    ///   - pageTabBar: pageTabBar
    ///   - index: 位置
    /// - Returns: 宽度
    @objc optional func pageTabBar(_ pageTabBar: HXPageTabBar, widthForIndicatorViewAt index: Int) -> CGFloat
    
    /// 切换动画，默认为none
    ///
    /// - Parameter pageTabBar: pageTabBar
    /// - Returns: 切换动画
    @objc optional func transitionAnimationType(in pageTabBar: HXPageTabBar) -> HXPageTabBarItemTransitionAnimationType
    
}

// MARK: -  HXPageTabBar选项卡
class HXPageTabBar: UIView {
    
    // MARK: -  Properties
    
    /// 关联的内容scrollView
    weak var contentScrollView: UIScrollView? {
        didSet {
            if contentScrollView != oldValue {
                setupContentScrollObserver()
            }
        }
    }
    
    /// 回调代理
    weak var delegate: HXPageTabBarDelegate?
    
    /// 数据源代理
    weak var dataSource: HXPageTabBarDataSource? {
        didSet {
            if let defaultIndex = dataSource?.defaultSelectedIndex?(in: self) {
                selectedIndex = min(max(0, defaultIndex), numberOfItems() - 1)
            }
            refreshCurrentState()
        }
    }
    
    /// 当前选中的下标，默认为0
    private (set) var selectedIndex: Int = 0
    
    /// 数据模型
    private var itemModels: [HXPageTabBarItemModel] = []
    
    /// 经过计算之后的实际item的间距
    private var itemSpacing: CGFloat = 10
    
    /// 内容视图滚动监听者
    private var scrollObserver: NSKeyValueObservation?
    
    /// 最近的contentOffset
    private var lastContentOffset: CGPoint = .zero
    
    /// collectionView
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.scrollsToTop = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(HXPageTabBarItem.self, forCellWithReuseIdentifier: HXPageTabBarItem.reuseID)
        return collectionView
    }()

    /// 指示器
    private var indicatorView: UIView?
    
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
        backgroundColor = .white
        addSubview(collectionView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
        refreshCurrentState()
    }
    
}

// MARK: -  UI
extension HXPageTabBar {
    
    /// 是否需要指示器
    ///
    /// - Returns: 是否需要指示器
    private func needsIndicatorView() -> Bool {
        return dataSource?.needsIndicatorView?(in: self) ?? true
    }
    
    /// 指示器的颜色
    ///
    /// - Returns: 指示器的颜色
    private func colorForIndicatorView() -> UIColor {
        return dataSource?.colorForIndicatorView?(in: self) ?? titleHighlightedColorForItem()
    }
    
    /// 指示器的高度，默认为3
    ///
    /// - Returns: 指示器的高度
    private func heightForIndicatorView() -> CGFloat {
        return dataSource?.heightForIndicatorView?(in: self) ?? 3
    }
    
    /// 指示器距离底部的位置，默认为5
    ///
    /// - Returns: 指示器距离底部的位置
    private func bottomForIndicatorView() -> CGFloat {
        return dataSource?.bottomForIndicatorView?(in: self) ?? 5
    }
    
    /// 指示器的宽度
    ///
    /// - Parameter index: 位置
    /// - Returns: 宽度
    private func widthForIndicatorView(at index: Int) -> CGFloat {
        /// 如果代理设置了宽度，直接返回代理宽度
        if let width = dataSource?.pageTabBar?(self, widthForIndicatorViewAt: index) {
            if width != HXPageViewAutomaticDimension {
                return width
            }
        }
        return widthForItem(at: index)
    }
    
    /// 计算item的宽度
    ///
    /// - Parameters:
    ///  - index: 位置
    ///  - font: 字体，默认为nil
    /// - Returns: 宽度
    private func widthForItem(at index: Int, font: UIFont? = nil) -> CGFloat {
        /// 如果代理设置了宽度，直接返回代理宽度
        if let width = dataSource?.pageTabBar?(self, widthForItemAt: index) {
            if width != HXPageViewAutomaticDimension {
                return width
            }
        }
        /// 如果没有title
        guard let title = dataSource?.pageTabBar(self, titleForItemAt: index) else {
            return 0
        }
        /// 计算宽度
        if let font = font {
            return HXPageTabBarUtil.stringWidth(with: title, font: font)
        }
        var titleFont: UIFont
        if selectedIndex == index {
            titleFont = titleHighlightedFontForItem()
        } else {
            titleFont = titleFontForItem()
        }
        return HXPageTabBarUtil.stringWidth(with: title, font: titleFont)
    }

    /// 获取item数目
    ///
    /// - Returns: item数目
    private func numberOfItems() -> Int {
        return dataSource?.numberOfItems(in: self) ?? 0
    }
    
    /// 标题
    ///
    /// - Parameter index: 位置
    /// - Returns: 标题
    private func titleForItem(at index: Int) -> String {
        return dataSource?.pageTabBar(self, titleForItemAt: index) ?? ""
    }
    
    /// 默认字体
    ///
    /// - Returns: 默认字体
    private func titleFontForItem() -> UIFont {
        return dataSource?.titleFontForItem?(in: self) ?? UIFont.systemFont(ofSize: 15)
    }
    
    /// 高亮字体
    ///
    /// - Returns: 高亮字体
    private func titleHighlightedFontForItem() -> UIFont {
        return dataSource?.titleHighlightedFontForItem?(in: self) ?? UIFont.systemFont(ofSize: 15)
    }
    
    /// 默认颜色
    ///
    /// - Returns: 默认颜色
    private func titleColorForItem() -> UIColor {
        return dataSource?.titleColorForItem?(in: self) ?? .lightGray
    }
    
    /// 高亮颜色
    ///
    /// - Returns: 高亮颜色
    private func titleHighlightedColorForItem() -> UIColor {
        return dataSource?.titleHighlightedColorForItem?(in: self) ?? .black
    }
    
    /// 切换动画
    ///
    /// - Returns: 切换动画
    private func transitionAnimationType() -> HXPageTabBarItemTransitionAnimationType {
        return dataSource?.transitionAnimationType?(in: self) ?? .none
    }
    
}

// MARK: -  Private Methods
extension HXPageTabBar {
    
    /// 设置内容视图监听者
    private func setupContentScrollObserver() {
        guard let contentScrollView = contentScrollView else { return }
        scrollObserver = contentScrollView.observe(\.contentOffset, options: [.new, .old]) { [weak self] (scrollView, changed) in
            guard let `self` = self,
                let newContentOffset = changed.newValue,
                let oldContentOffset = changed.oldValue else { return }
            let isDragging = scrollView.isTracking || scrollView.isDecelerating
            if newContentOffset != oldContentOffset && isDragging {
                // 设置了新的contentOffset，才做处理
                self.contentSrollViewDidChanged(contentOffset: newContentOffset)
            }
            self.lastContentOffset = newContentOffset
        }
    }
    
    /// 刷新当前状态
    private func refreshCurrentState() {
        let itemCount = numberOfItems()
        itemSpacing = 20
        /// 如果设置了间距
        if let spacing = dataSource?.spacingForItem?(in: self) {
            itemSpacing = spacing
        }
        /// 计算当item总宽度小于HXCategoryView的宽度时，居中显示所有item，并重新计算itemSpacing，
        var totalItemWidth: CGFloat = 0
        var totalSpacingWidth: CGFloat = itemSpacing
        for i in 0 ..< itemCount {
            totalItemWidth += widthForItem(at: i)
            totalSpacingWidth += itemSpacing
        }
        let relayoutWhenWidthNotEnough = dataSource?.relayoutWhenWidthNotEnough?(in: self) ?? true
        if totalItemWidth + totalSpacingWidth < bounds.width && relayoutWhenWidthNotEnough {
            let itemSpacingCount: Int = itemCount + 1
            let newTotalSpacingWidth = bounds.width - totalItemWidth
            itemSpacing = newTotalSpacingWidth / CGFloat(itemSpacingCount)
        }
        /// 重新设置模型
        itemModels.removeAll()
        var totalWidth: CGFloat = itemSpacing
        for i in 0 ..< itemCount {
            let model = itemModel(at: i)
            itemModels.append(model)
            totalWidth += model.itemWidth + itemSpacing
        }
        let selectedItemFrame = itemFrame(at: selectedIndex)
        /// 设置指示器
        if needsIndicatorView() {
            if indicatorView == nil {
                indicatorView = UIView(frame: .zero)
                collectionView.addSubview(indicatorView!)
            }
            indicatorView?.frame = CGRect(x: 0, y: 0, width: widthForIndicatorView(at: selectedIndex), height: heightForIndicatorView())
            indicatorView?.center = CGPoint(x: selectedItemFrame.midX, y: bounds.height - heightForIndicatorView() / 2 - bottomForIndicatorView())
            indicatorView?.backgroundColor = colorForIndicatorView()
            indicatorView?.layer.cornerRadius = heightForIndicatorView() / 2
        }
        /// 设置初始滚动位置
        let targetX = selectedItemFrame.minX - bounds.width / 2 + selectedItemFrame.width / 2
        collectionView.contentSize = CGSize(width: totalWidth, height: bounds.height)
        collectionView.setContentOffset(CGPoint(x: max(min(totalWidth - bounds.width, targetX), 0), y: 0), animated: false)
        if let contentScrollView = contentScrollView {
            if contentScrollView.frame.equalTo(CGRect.zero) && contentScrollView.superview != nil {
                contentScrollView.superview?.setNeedsLayout()
                contentScrollView.superview?.layoutIfNeeded()
            }
            contentScrollView.setContentOffset(CGPoint(x: CGFloat(selectedIndex) * contentScrollView.bounds.width, y: 0), animated: false)
        }
        /// reload
        collectionView.reloadData()
    }
    
    /// item的frame
    ///
    /// - Parameter index: 位置
    private func itemFrame(at index: Int) -> CGRect {
        var itemX = itemSpacing
        var itemWidth: CGFloat = 0
        for i in 0 ..< itemModels.count {
            let model = itemModels[i]
            if i < index {
                itemX += model.itemWidth + itemSpacing
            } else if i == index {
                itemWidth = model.itemWidth
            }
        }
        return CGRect(x: itemX, y: 0, width: itemWidth, height: bounds.height)
    }
    
    /// itemModel
    ///
    /// - Parameters:
    ///   - index: 位置
    ///   - percent: 滑动进度，默认为1
    /// - Returns: model
    private func itemModel(at index: Int, percent: CGFloat = 1) -> HXPageTabBarItemModel {
        let title = titleForItem(at: index)
        var titleFont: UIFont
        var titleHighlightedFont: UIFont
        var titleColor: UIColor
        var titleHighlightedColor: UIColor
        var isSelected: Bool
        var itemWidth: CGFloat
        if index != selectedIndex {
            isSelected = false
            titleFont = HXPageTabBarUtil.interpolationFont(fromFont: titleHighlightedFontForItem(), toFont: titleFontForItem(), percent: percent)
            titleHighlightedFont = titleHighlightedFontForItem()
            titleColor = HXPageTabBarUtil.interpolationColor(fromColor: titleHighlightedColorForItem(), toColor: titleColorForItem(), percent: percent)
            titleHighlightedColor = titleHighlightedColorForItem()
            itemWidth = widthForItem(at: index, font: titleFont)
        } else {
            isSelected = true
            titleHighlightedFont = HXPageTabBarUtil.interpolationFont(fromFont: titleFontForItem(), toFont: titleHighlightedFontForItem(), percent: percent)
            titleFont = titleFontForItem()
            titleHighlightedColor = HXPageTabBarUtil.interpolationColor(fromColor: titleColorForItem(), toColor: titleHighlightedColorForItem(), percent: percent)
            titleColor = titleColorForItem()
            itemWidth = widthForItem(at: index, font: titleHighlightedFont)
        }
        let itemModel = HXPageTabBarItemModel(title: title, titleFont: titleFont, titleHighlightedFont: titleHighlightedFont, titleColor: titleColor, titleHighlightedColor: titleHighlightedColor, itemWidth: itemWidth, isSelected: isSelected)
        return itemModel
    }
    
    /// 滑动中更新item
    ///
    /// - Parameters:
    ///   - fromIndex: fromIndex
    ///   - toIndex: toIndex
    ///   - percent: percent
    private func refreshItemState(fromIndex: Int, toIndex: Int, percent: CGFloat) {
        guard let fromItem = collectionView.cellForItem(at: IndexPath(item: fromIndex, section: 0)) as? HXPageTabBarItem,
            let toItem = collectionView.cellForItem(at: IndexPath(item: toIndex, section: 0)) as? HXPageTabBarItem else {
                return
        }
        if transitionAnimationType() == .smoothness {
            let fromModel = itemModel(at: fromIndex, percent: 1 - percent)
            let toModel = itemModel(at: toIndex, percent: 1 - percent)
            fromItem.configItem(itemModel: fromModel)
            toItem.configItem(itemModel: toModel)
            collectionView.collectionViewLayout.invalidateLayout()
        }
        /// 处理指示器的位置
        if let indicatorView = indicatorView {
            let fromItemFrame = itemFrame(at: fromIndex)
            let toItemFrame = itemFrame(at: toIndex)
            let centerX = HXPageTabBarUtil.interpolationValue(fromValue: fromItemFrame.midX, toValue: toItemFrame.midX, percent: percent)
            let centerY = indicatorView.center.y
            let fromWidth = widthForIndicatorView(at: fromIndex)
            let toWidth = widthForIndicatorView(at: toIndex)
            let indicatorWidth = HXPageTabBarUtil.interpolationValue(fromValue: fromWidth, toValue: toWidth, percent: percent)
            indicatorView.frame = CGRect(x: 0, y: 0, width: indicatorWidth, height: indicatorView.frame.height)
            indicatorView.center = CGPoint(x: centerX, y: centerY)
        }
    }
    
    /// 内容视图滚动监听
    ///
    /// - Parameter contentOffset: 偏移
    private func contentSrollViewDidChanged(contentOffset: CGPoint) {
        guard let contentScrollView = contentScrollView else { return }
        let itemCount = numberOfItems()
        let ratio = contentOffset.x / contentScrollView.bounds.width
        if ratio > CGFloat(itemCount - 1) || ratio < 0 {
            /// 如果越界，不做处理
            return
        }
        if (contentOffset.x == 0 && selectedIndex == 0 && lastContentOffset.x == 0) {
            // 滚动到了最左边，且已经选中了第一个，且之前的contentOffset.x为0，不做处理
            return
        }
        let maxContentOffsetX = contentScrollView.contentSize.width - contentScrollView.bounds.width
        if (contentOffset.x == maxContentOffsetX && selectedIndex == itemCount - 1 && lastContentOffset.x == maxContentOffsetX) {
            //滚动到了最右边，且已经选中了最后一个，且之前的contentOffset.x为maxContentOffsetX，不做处理
            return
        }
        let currentIndex = Int(ratio)
        let remainderRatio = ratio - CGFloat(currentIndex)
        /// 是否忽略此次滚动处理
        let isIgnoreScroll = lastContentOffset.x == contentOffset.x && selectedIndex == currentIndex
        if remainderRatio == 0 {
            // 滑动翻页，更新选中状态， 忽略重复的情况
            if !isIgnoreScroll {
                selectedItem(at: currentIndex, shouldHandleContentScrollView: false)
            }
        } else {
            /// 滑动太快，remainderRatio没有变成0，但是已经翻页了
            if (abs(ratio - CGFloat(selectedIndex)) > 1) {
                var targetIndex = currentIndex
                if (ratio < CGFloat(selectedIndex)) {
                    targetIndex += 1
                }
                selectedItem(at: targetIndex, shouldHandleContentScrollView: false)
            }
        }
        if !isIgnoreScroll {
            let fromIndex = selectedIndex
            var toIndex: Int = 0
            var percent: CGFloat = 0
            if selectedIndex == currentIndex {
                toIndex = currentIndex + 1
                percent = remainderRatio
            } else {
                toIndex = currentIndex
                percent = 1 - remainderRatio
            }
            refreshItemState(fromIndex: fromIndex, toIndex: toIndex, percent: percent)
            delegate?.pageTabBar?(self, didScrollItem: fromIndex, toIndex: toIndex, percent: percent)
        }
    }
    
    /// 设置选中状态
    ///
    /// - Parameters:
    ///   - index: 位置
    ///   - flag: 是否同步滚动内容视图
    private func selectedItem(at index: Int, shouldHandleContentScrollView flag: Bool) {
        let itemCount = numberOfItems()
        if index > itemCount - 1 || index < 0 {
            /// 如果越界，不做处理
            return
        }
        if selectedIndex == index {
            /// 如果index没有变化，不做处理
            return
        }
        /// 更新选中状态
        let lastIndex = selectedIndex
        selectedIndex = index
        var lastModel = itemModels[lastIndex]
        var selectedModel = itemModels[selectedIndex]
        lastModel.isSelected = false
        selectedModel.isSelected = true
        itemModels.replaceSubrange(lastIndex ..< lastIndex + 1, with: [lastModel])
        itemModels.replaceSubrange(selectedIndex ..< selectedIndex + 1, with: [selectedModel])
        collectionView.reloadData()
        collectionView.scrollToItem(at: IndexPath(item: selectedIndex, section: 0), at: .centeredHorizontally, animated: true)
        /// 处理指示器
        if let indicatorView = indicatorView {
            let selectedItemFrame = itemFrame(at: selectedIndex)
            let indicatorWidth = widthForIndicatorView(at: selectedIndex)
            let centerY = indicatorView.center.y
            UIView.animate(withDuration: 0.2) {
                indicatorView.frame = CGRect(x: 0, y: 0, width: indicatorWidth, height: indicatorView.frame.height)
                indicatorView.center = CGPoint(x: selectedItemFrame.midX, y: centerY)
            }
        }
        /// 处理内容视图
        if let contentScrollView = contentScrollView {
            if flag {
                /// 内容视图同步滑动
                contentScrollView.setContentOffset(CGPoint(x: CGFloat(selectedIndex) * contentScrollView.bounds.width, y: 0), animated: true)
            }
        }
        /// 回调
        delegate?.pageTabBar?(self, didSelectedItemAt: selectedIndex)
    }
    
}

// MARK: -  Public Methods
extension HXPageTabBar {
    
    /// 设置选中位置
    ///
    /// - Parameters:
    ///   - index: 位置
    ///   - flag: 是否同时滚动内容视图
    func setSelectedIndex(_ index: Int, shouldHandleContentScrollView flag: Bool) {
        selectedItem(at: index, shouldHandleContentScrollView: flag)
    }
    
    /// 重新加载
    func reloadData() {
        refreshCurrentState()
    }
    
}

// MARK: -  UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension HXPageTabBar: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HXPageTabBarItem.reuseID, for: indexPath) as! HXPageTabBarItem
        cell.configItem(itemModel: itemModels[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedItem(at: indexPath.item, shouldHandleContentScrollView: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemModels[indexPath.item].itemWidth, height: bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return itemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return itemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: itemSpacing, bottom: 0, right: itemSpacing)
    }
    
}
