//
//  HXPageViewController.swift
//  HXPageViewController
//
//  Created by HongXiangWen on 2019/1/10.
//  Copyright © 2019年 WHX. All rights reserved.
//

import UIKit

// MARK: -  行为代理
@objc public protocol HXPageViewControllerDelegate: class {
    
    /// 将要切换子控制器
    ///
    /// - Parameters:
    ///   - pageViewController: pageViewController
    ///   - fromVC: fromVC
    ///   - toVC: toVC
    @objc optional func pageViewController(_ pageViewController: HXPageViewController, willTransition fromVC: UIViewController, toVC: UIViewController)
    
    /// 完成切换子控制器
    ///
    /// - Parameters:
    ///   - pageViewController: pageViewController
    ///   - fromVC: fromVC
    ///   - toVC: toVC
    @objc optional func pageViewController(_ pageViewController: HXPageViewController, didFinishedTransition fromVC: UIViewController, toVC: UIViewController)
    
    /// 取消切换子控制器
    ///
    /// - Parameters:
    ///   - pageViewController: pageViewController
    ///   - fromVC: fromVC
    ///   - toVC: toVC
    @objc optional func pageViewController(_ pageViewController: HXPageViewController, didCancelledTransition fromVC: UIViewController, toVC: UIViewController)
    
    /// 拖动状态回调
    ///
    /// - Parameters:
    ///   - pageViewController: pageViewController
    ///   - fromIndex: fromIndex
    ///   - toIndex: toIndex
    ///   - percent: 进度百分比
    @objc optional func pageViewController(_ pageViewController: HXPageViewController, dragging fromIndex: Int, toIndex: Int, percent: CGFloat)
    
    /// 选中index的回调
    ///
    /// - Parameters:
    ///   - pageViewController: pageViewController
    ///   - index: 当前index
    @objc optional func pageViewController(_ pageViewController: HXPageViewController, didSelected index: Int)
    
}

// MARK: -  数据源代理
@objc public protocol HXPageViewControllerDataSource: class {
    
    /// 选项数目
    ///
    /// - Parameter pageViewController: pageViewController
    /// - Returns: 选项数目
    func numberOfItems(in pageViewController: HXPageViewController) -> Int
    
    /// index位置的item标题
    ///
    /// - Parameters:
    ///   - pageViewController: pageViewController
    ///   - index: 位置
    /// - Returns: index位置的item标题
    func pageViewController(_ pageViewController: HXPageViewController, titleForItemAt index: Int) -> String
    
    /// index位置的childViewController
    ///
    /// - Parameters:
    ///   - pageViewController: pageViewController
    ///   - index: 位置
    /// - Returns: index位置的childViewController
    func pageViewController(_ pageViewController: HXPageViewController, childViewContollerAt index: Int) -> UIViewController
    
    /// tabbar的frame，默认为 (0, 0, bounds.width, 50)
    ///
    /// - Parameter pageViewController: pageViewController
    /// - Returns: tabbar的frame
    @objc optional func tabbarFrame(in pageViewController: HXPageViewController) -> CGRect
    
    /// container的frame，默认为 (0, 50, bounds.width, bounds.height - 50)
    ///
    /// - Parameter pageViewController: pageViewController
    /// - Returns: container的frame
    @objc optional func containerFrame(in pageViewController: HXPageViewController) -> CGRect
    
    /// 默认选中位置，默认为0
    ///
    /// - Parameter pageViewController: pageViewController
    /// - Returns: 默认选中位置
    @objc optional func defaultSelectedIndex(in pageViewController: HXPageViewController) -> Int
    
    /// index位置的item宽度，默认为自适应
    ///
    /// - Parameters:
    ///   - pageViewController: pageViewController
    ///   - index: 位置
    /// - Returns: index位置的item宽度
    @objc optional func pageViewController(_ pageViewController: HXPageViewController, widthForItemAt index: Int) -> CGFloat
    
    /// 默认字体，默认为15号系统字体
    ///
    /// - Parameter pageViewController: pageViewController
    /// - Returns: 默认字体
    @objc optional func titleFontForItem(in pageViewController: HXPageViewController) -> UIFont
    
    /// 高亮字体，默认为15号系统字体
    ///
    /// - Parameter pageViewController: pageViewController
    /// - Returns: 高亮字体
    @objc optional func titleHighlightedFontForItem(in pageViewController: HXPageViewController) -> UIFont
    
    /// 默认字体颜色，默认为浅灰色
    ///
    /// - Parameter pageViewController: pageViewController
    /// - Returns: 默认字体颜色
    @objc optional func titleColorForItem(in pageViewController: HXPageViewController) -> UIColor
    
    /// 高亮字体颜色，默认为黑色
    ///
    /// - Parameter pageViewController: pageViewController
    /// - Returns: 高亮字体颜色
    @objc optional func titleHighlightedColorForItem(in pageViewController: HXPageViewController) -> UIColor
    
    /// item之间的间距，默认为10
    ///
    /// - Parameter pageViewController: pageViewController
    /// - Returns: item之间的间距
    @objc optional func spacingForItem(in pageViewController: HXPageViewController) -> CGFloat
    
    /// 是否开启当item总宽度小于总的宽度时居中显示所有item，并重新计算item之间的间距，默认开启
    ///
    /// - Parameter pageViewController: pageViewController
    /// - Returns: 是否开启
    @objc optional func relayoutWhenWidthNotEnough(in pageViewController: HXPageViewController) -> Bool
    
    /// 是否需要指示器，默认为true
    ///
    /// - Parameter pageViewController: pageViewController
    /// - Returns: 是否需要指示器
    @objc optional func needsIndicatorView(in pageViewController: HXPageViewController) -> Bool
    
    /// 指示器的颜色，默认为选中字体颜色
    ///
    /// - Parameter pageViewController: pageViewController
    /// - Returns: 指示器的颜色
    @objc optional func colorForIndicatorView(in pageViewController: HXPageViewController) -> UIColor
    
    /// 指示器的高度，默认为3
    ///
    /// - Parameter pageViewController: pageViewController
    /// - Returns: 指示器的高度
    @objc optional func heightForIndicatorView(in pageViewController: HXPageViewController) -> CGFloat
    
    /// 指示器距离底部的位置，默认为5
    ///
    /// - Parameter pageViewController: pageViewController
    /// - Returns: 指示器距离底部的位置
    @objc optional func bottomForIndicatorView(in pageViewController: HXPageViewController) -> CGFloat
    
    /// 指示器的宽度，默认自适应
    ///
    /// - Parameters:
    ///   - pageViewController: pageViewController
    ///   - index: 位置
    /// - Returns: 宽度
    @objc optional func pageViewController(_ pageViewController: HXPageViewController, widthForIndicatorViewAt index: Int) -> CGFloat
    
    /// 切换动画，默认为none
    ///
    /// - Parameter pageViewController: pageViewController
    /// - Returns: 切换动画
    @objc optional func transitionAnimationType(in pageViewController: HXPageViewController) -> HXPageTabBarItemTransitionAnimationType
    
}

// MARK: -  封装了pageContainer和pageTabBar的控制器
open class HXPageViewController: UIViewController {

    // MARK: -  Properties
    
    ///数据源代理
    open weak var dataSource: HXPageViewControllerDataSource?
    
    /// 行为代理
    open weak var delegate: HXPageViewControllerDelegate?
    
    /// 当前选中的下标
    open var selectedIndex: Int {
        return pageTabBar.selectedIndex
    }
    
    /// container
    private lazy var pageContainer: HXPageContainer = {
        let pageContainer = HXPageContainer()
        pageContainer.dataSource = self
        pageContainer.delegate = self
        return pageContainer
    }()
    
    /// tabbar
    private lazy var pageTabBar: HXPageTabBar = {
        let pageTabBar = HXPageTabBar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 50))
        pageTabBar.dataSource = self
        return pageTabBar
    }()
    
    // MARK: -  Life Cycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pageTabBar.frame = preferredTabbarFrame()
        pageContainer.view.frame = preferredContainerFrame()
    }
    
    // MARK: - Private Methods
    
    private func setup() {
        addChild(pageContainer)
        pageContainer.didMove(toParent: self)
        view.addSubview(pageContainer.view)
        pageTabBar.contentScrollView = pageContainer.scrollView
        view.addSubview(pageTabBar)
    }
    
    // MARK: -  Public Methods，各种配置，子类可以覆写这些方法

    open func preferredNumberOfItems() -> Int {
        return dataSource?.numberOfItems(in: self) ?? 0
    }
    
    open func preferredTitleForItem(at index: Int) -> String {
        return dataSource?.pageViewController(self, titleForItemAt: index) ?? ""
    }
    
    open func preferredChildViewContoller(at index: Int) -> UIViewController {
        return dataSource?.pageViewController(self, childViewContollerAt: index) ?? UIViewController()
    }
    
    open func preferredTabbarFrame() -> CGRect {
        return dataSource?.tabbarFrame?(in: self) ?? CGRect(x: 0, y: 0, width: view.bounds.width, height: 50)
    }
    
    open func preferredContainerFrame() -> CGRect {
        return dataSource?.containerFrame?(in: self) ?? CGRect(x: 0, y: 50, width: view.bounds.width, height: view.bounds.height - 50)
    }
    
    open func preferredDefaultSelectedIndex() -> Int {
        return dataSource?.defaultSelectedIndex?(in: self) ?? 0
    }
    
    open func preferredWidthForItem(at index: Int) -> CGFloat {
        return dataSource?.pageViewController?(self, widthForItemAt: index) ?? HXPageViewAutomaticDimension
    }
    
    open func preferredTitleFontForItem() -> UIFont {
        return dataSource?.titleFontForItem?(in: self) ?? UIFont.systemFont(ofSize: 15)
    }
    
    open func preferredTitleHighlightedFontForItem() -> UIFont {
        return dataSource?.titleHighlightedFontForItem?(in: self) ?? UIFont.systemFont(ofSize: 15)
    }
    
    open func preferredTitleColorForItem() -> UIColor {
        return dataSource?.titleColorForItem?(in: self) ?? .lightGray
    }
    
    open func preferredTitleHighlightedColorForItem() -> UIColor {
        return dataSource?.titleHighlightedColorForItem?(in: self) ?? .black
    }
    
    open func preferredSpacingForItem() -> CGFloat {
        return dataSource?.spacingForItem?(in: self) ?? 10
    }
    
    open func preferredRelayoutWhenWidthNotEnough() -> Bool {
        return dataSource?.relayoutWhenWidthNotEnough?(in: self) ?? true
    }
    
    open func preferredNeedsIndicatorView() -> Bool {
        return dataSource?.needsIndicatorView?(in: self) ?? true
    }
    
    open func preferredColorForIndicatorView() -> UIColor {
        return dataSource?.colorForIndicatorView?(in: self) ?? preferredTitleHighlightedColorForItem()
    }
    
    open func preferredHeightForIndicatorView() -> CGFloat {
        return dataSource?.heightForIndicatorView?(in: self) ?? 3
    }
   
    open func preferredBottomForIndicatorView() -> CGFloat {
        return dataSource?.bottomForIndicatorView?(in: self) ?? 5
    }
    
    open func preferredWidthForIndicatorView(at index: Int) -> CGFloat {
        return dataSource?.pageViewController?(self, widthForIndicatorViewAt: index) ?? HXPageViewAutomaticDimension
    }
    
    open func preferredTransitionAnimationType() -> HXPageTabBarItemTransitionAnimationType {
        return dataSource?.transitionAnimationType?(in: self) ?? .none
    }
}

// MARK: -  HXPageContainerDataSource
extension HXPageViewController: HXPageContainerDataSource {
    
    public func numberOfChildViewControllers(in pageContainer: HXPageContainer) -> Int {
        return preferredNumberOfItems()
    }
    
    public func pageContainer(_ pageContainer: HXPageContainer, childViewContollerAt index: Int) -> UIViewController {
        return preferredChildViewContoller(at: index)
    }
    
    public func defaultCurrentIndex(in pageContainer: HXPageContainer) -> Int {
        return preferredDefaultSelectedIndex()
    }
    
}

// MARK: -  HXPageContainerDelegate
extension HXPageViewController: HXPageContainerDelegate {
    
    public func pageContainer(_ pageContainer: HXPageContainer, willTransition fromVC: UIViewController, toVC: UIViewController) {
        delegate?.pageViewController?(self, willTransition: fromVC, toVC: toVC)
    }
    
    public func pageContainer(_ pageContainer: HXPageContainer, didFinishedTransition fromVC: UIViewController, toVC: UIViewController) {
        delegate?.pageViewController?(self, didFinishedTransition: fromVC, toVC: toVC)
    }
    
    public func pageContainer(_ pageContainer: HXPageContainer, didCancelledTransition fromVC: UIViewController, toVC: UIViewController) {
        delegate?.pageViewController?(self, didCancelledTransition: fromVC, toVC: toVC)
    }
    
    public func pageContainer(_ pageContainer: HXPageContainer, dragging fromIndex: Int, toIndex: Int, percent: CGFloat) {
        delegate?.pageViewController?(self, dragging: fromIndex, toIndex: toIndex, percent: percent)
    }
    
    public func pageContainer(_ pageContainer: HXPageContainer, didSelected index: Int) {
        delegate?.pageViewController?(self, didSelected: index)
    }
    
}

// MARK: -  HXPageTabBarDelegate
extension HXPageViewController: HXPageTabBarDataSource {
    
    public func numberOfItems(in pageTabBar: HXPageTabBar) -> Int {
        return preferredNumberOfItems()
    }
    
    public func pageTabBar(_ pageTabBar: HXPageTabBar, titleForItemAt index: Int) -> String {
        return preferredTitleForItem(at: index)
    }
    
    public func defaultSelectedIndex(in pageTabBar: HXPageTabBar) -> Int {
        return preferredDefaultSelectedIndex()
    }
    
    public func pageTabBar(_ pageTabBar: HXPageTabBar, widthForIndicatorViewAt index: Int) -> CGFloat {
        return preferredWidthForIndicatorView(at: index)
    }
    
    public func pageTabBar(_ pageTabBar: HXPageTabBar, widthForItemAt index: Int) -> CGFloat {
        return preferredWidthForItem(at: index)
    }
    
    public func colorForIndicatorView(in pageTabBar: HXPageTabBar) -> UIColor {
        return preferredColorForIndicatorView()
    }
    
    public func spacingForItem(in pageTabBar: HXPageTabBar) -> CGFloat {
        return preferredSpacingForItem()
    }
    
    public func needsIndicatorView(in pageTabBar: HXPageTabBar) -> Bool {
        return preferredNeedsIndicatorView()
    }
    
    public func titleFontForItem(in pageTabBar: HXPageTabBar) -> UIFont {
        return preferredTitleFontForItem()
    }
    
    public func titleColorForItem(in pageTabBar: HXPageTabBar) -> UIColor {
        return preferredTitleColorForItem()
    }
    
    public func bottomForIndicatorView(in pageTabBar: HXPageTabBar) -> CGFloat {
        return preferredBottomForIndicatorView()
    }
    
    public func heightForIndicatorView(in pageTabBar: HXPageTabBar) -> CGFloat {
        return preferredHeightForIndicatorView()
    }
    
    public func relayoutWhenWidthNotEnough(in pageTabBar: HXPageTabBar) -> Bool {
        return preferredRelayoutWhenWidthNotEnough()
    }
    
    public func titleHighlightedFontForItem(in pageTabBar: HXPageTabBar) -> UIFont {
        return preferredTitleHighlightedFontForItem()
    }
    
    public func titleHighlightedColorForItem(in pageTabBar: HXPageTabBar) -> UIColor {
        return preferredTitleHighlightedColorForItem()
    }
    
    public func transitionAnimationType(in pageTabBar: HXPageTabBar) -> HXPageTabBarItemTransitionAnimationType {
        return preferredTransitionAnimationType()
    }
}

