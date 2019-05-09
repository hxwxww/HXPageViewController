//
//  HXPageContainer.swift
//  HXPageViewController
//
//  Created by HongXiangWen on 2019/1/7.
//  Copyright © 2019年 WHX. All rights reserved.
//

import UIKit

// MARK: -  行为代理
@objc protocol HXPageContainerDelegate: class {
    
    /// 将要切换子控制器
    ///
    /// - Parameters:
    ///   - pageContainer: pageContainer
    ///   - fromVC: fromVC
    ///   - toVC: toVC
    @objc optional func pageContainer(_ pageContainer: HXPageContainer, willTransition fromVC: UIViewController, toVC: UIViewController)
    
    /// 完成切换子控制器
    ///
    /// - Parameters:
    ///   - pageContainer: pageContainer
    ///   - fromVC: fromVC
    ///   - toVC: toVC
    @objc optional func pageContainer(_ pageContainer: HXPageContainer, didFinishedTransition fromVC: UIViewController, toVC: UIViewController)
    
    /// 取消切换子控制器
    ///
    /// - Parameters:
    ///   - pageContainer: pageContainer
    ///   - fromVC: fromVC
    ///   - toVC: toVC
    @objc optional func pageContainer(_ pageContainer: HXPageContainer, didCancelledTransition fromVC: UIViewController, toVC: UIViewController)
    
    /// 拖动状态回调
    ///
    /// - Parameters:
    ///   - pageContainer: pageContainer
    ///   - fromIndex: fromIndex
    ///   - toIndex: toIndex
    ///   - percent: 进度百分比
    @objc optional func pageContainer(_ pageContainer: HXPageContainer, dragging fromIndex: Int, toIndex: Int, percent: CGFloat)
    
    /// 选中index的回调
    ///
    /// - Parameters:
    ///   - pageContainer: pageContainer
    ///   - index: 当前index
    @objc optional func pageContainer(_ pageContainer: HXPageContainer, didSelected index: Int)

}

// MARK: -  数据源代理
@objc protocol HXPageContainerDataSource: class {
    
    /// 获取childViewController的数目
    ///
    /// - Parameter pageContainer: pageContainer
    /// - Returns: childViewController的数目
    func numberOfChildViewControllers(in pageContainer: HXPageContainer) -> Int
    
    /// 获取index位置的childViewController
    ///
    /// - Parameters:
    ///   - pageContainer: pageContainer
    ///   - index: 位置
    /// - Returns: index位置的childViewController
    func pageContainer(_ pageContainer: HXPageContainer, childViewContollerAt index: Int) -> UIViewController
    
    /// 默认选中位置，默认为0
    ///
    /// - Parameter pageTabBar: pageContainer
    /// - Returns: 默认选中位置
    @objc optional func defaultCurrentIndex(in pageContainer: HXPageContainer) -> Int
    
}

// MARK: -  重新加载子控制器的方式
enum HXpageContainerReloadType {
    /// 所有
    case all
    /// 除了当前
    case exceptCurrentIndex
    /// 都不重新加载
    case notReload
}

// MARK: -  HXPageContainer内容控制器
class HXPageContainer: UIViewController {

    // MARK: - Properties
    
    /// 数据源代理
    weak var dataSource: HXPageContainerDataSource? {
        didSet {
            if let defaultIndex = dataSource?.defaultCurrentIndex?(in: self) {
                currentIndex = min(max(0, defaultIndex), numberOfChildViewControllers() - 1)
            }
        }
    }
    
    /// 代理
    weak var delegate: HXPageContainerDelegate?
    
    /// 当前的index
    private (set) var currentIndex: Int = 0
    
    /// 当前子控制器
    var currentChildViewController: UIViewController? {
        return childViewController(at: currentIndex)
    }
    
    /// 滚动视图
    lazy var scrollView: HXPageContentView = {
        let scrollView = HXPageContentView(frame: view.bounds)
        scrollView.delegate = self
        return scrollView
    }()
    
    /// 缓存的子控制器
    private var cacheViewControllers: [Int: UIViewController] = [:]
    
    /// 初始滑动的x偏移量
    private var lastOffsetX: CGFloat = 0
    
    /// 初始滑动的index
    private var lastIndex: Int = 0
    
    /// 是否已经处理了子控制器的生命周期函数
    private var hasProcessAppearance: Bool = false
    
    /// 可能的下一页
    private var potentialIndex: Int = -999
    
    /// 设置false，手动控制子控制器的生命周期
    override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return false
    }
    
    // MARK: -  Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        reloadChildViewControllers()
    }
    
    deinit {
        /// 修复在iOS10以下的设备上仍然注册kvo的bug
        /*
         *** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'An instance 0x7c33d400 of class HXNovelReader.HXPageContentView was deallocated while key value observers were still registered with it. Current observation info: <NSKeyValueObservationInfo 0x7b7e3f80> (
         <NSKeyValueObservance 0x7b7e4100: Observer: 0x7b7e3f60, Key path: contentOffset, Options: <New: YES, Old: YES, Prior: NO> Context: 0x0, Property: 0x7b78a1c0>
         )'
         */
        scrollView.observationInfo = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentChildViewController?.beginAppearanceTransition(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        currentChildViewController?.endAppearanceTransition()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        currentChildViewController?.beginAppearanceTransition(false, animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        currentChildViewController?.endAppearanceTransition()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        /// 重新布局
        relayoutScrollView()
    }
    
    /// 收到内存警告
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        /// 除了当前子控制器，清空所有 
        clearCaches(.exceptCurrentIndex)
    }
    
}

// MARK: -  Private Methods
extension HXPageContainer {
    
    /// 初始化设置
    private func setup() {
        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = .clear
        view.addSubview(scrollView)
        scrollView.didSetContentOffsetCallback = { [weak self] (index, animated) in
            guard let `self` = self else { return }
            self.setCurrentIndex(index, animated: animated)
        }
    }

    /// 重新加载子控制器
    ///
    /// - Parameter flag: 是否回调子控制器生命周期函数，默认false
    private func reloadChildViewControllers(shouldForwardAppearance flag: Bool = false) {
        guard isViewLoaded else { return }
        /// 重新布局scrollView
        relayoutScrollView()
        /// 添加当前子控制器
        addChildViewContoller(at: currentIndex, shouldForwardAppearance: flag)
    }
    
    /// 重新布局scrollView
    private func relayoutScrollView() {
        guard isViewLoaded else { return }
        let lastFrame = scrollView.frame
        let controllerCount = numberOfChildViewControllers()
        scrollView.frame = view.bounds
        scrollView.contentSize = CGSize(width: CGFloat(controllerCount) * scrollView.bounds.width, height: scrollView.bounds.height)
        /// 设置contentOffset，如果正在拖动，不做设置
        if !scrollView.isTracking && !scrollView.isDecelerating {
            let currentOffsetX = scrollView.calculateContentOffset(with: currentIndex).x
            scrollView.contentOffset = CGPoint(x: currentOffsetX, y: 0)
        }
        if lastFrame != scrollView.frame {
            /// 重新设置子视图的位置
            for (index, childViewController) in cacheViewControllers {
                childViewController.view.frame = scrollView.calculateVisibleViewControllerFrame(with: index)
            }
        }
        resetCurrentState()
    }
    
    /// 重新设置当前状态
    private func resetCurrentState() {
        hasProcessAppearance = false
        lastIndex = currentIndex
        lastOffsetX = scrollView.contentOffset.x
        /// 重新设置currentIndex
        currentIndex = scrollView.calculateIndex()
    }
    
    /// 获取子控制器数目
    ///
    /// - Returns: 子控制器数目
    private func numberOfChildViewControllers() -> Int {
        return dataSource?.numberOfChildViewControllers(in: self) ?? 0
    }
    
    /// 获取子控制器
    ///
    /// - Parameter index: 子控制器的位置
    /// - Returns: 子控制器
    private func childViewController(at index: Int) -> UIViewController? {
        /// 如果index越界，返回nil
        if index < 0 || index >= numberOfChildViewControllers()  {
            return nil
        }
        /// 如果有缓存，直接取缓存
        if let cacheViewController = cacheViewControllers[index] {
            return cacheViewController
        }
        return dataSource?.pageContainer(self, childViewContollerAt: index)
    }
    
    /// 添加子控制器
    ///
    /// - Parameters:
    ///   - index: 位置
    ///   - flag: 是否回调子控制器的生命周期函数，默认false
    /// - Returns: 子控制器
    @discardableResult
    private func addChildViewContoller(at index: Int, shouldForwardAppearance flag: Bool = false) -> UIViewController? {
        guard let childViewController = childViewController(at: index) else {
            return nil
        }
        if children.contains(childViewController) {
            return childViewController
        }
        /// 设置frame
        childViewController.view.frame = scrollView.calculateVisibleViewControllerFrame(with: index)
        scrollView.addSubview(childViewController.view)
        /// 回调子控制器的生命周期函数
        if flag {
            childViewController.beginAppearanceTransition(true, animated: true)
            childViewController.endAppearanceTransition()
        }
        /// 添加
        addChild(childViewController)
        childViewController.didMove(toParent: self)
        /// 添加到缓存中
        cacheViewControllers[index] = childViewController
        return childViewController
    }

    /// 清除缓存
    ///
    /// - Parameter clearType: 清除缓存的方式，默认清除所有
    private func clearCaches(_ clearType: HXpageContainerReloadType = .all) {
        /// 移除子控制器
        for (index, childViewController) in cacheViewControllers {
            if clearType == .exceptCurrentIndex {
                if index == currentIndex && index < numberOfChildViewControllers() {
                    continue
                }
            } else if clearType == .notReload {
                if index < numberOfChildViewControllers() {
                    continue
                }
            }
            removeChildViewContoller(childViewController)
            cacheViewControllers.removeValue(forKey: index)
        }
    }
    
    /// 移除子控制器
    ///
    /// - Parameter childViewContoller: 子控制器
    private func removeChildViewContoller(_ childViewController: UIViewController) {
        childViewController.willMove(toParent: nil)
        childViewController.view.removeFromSuperview()
        childViewController.removeFromParent()
    }
    
    /// 开始更新子控制器
    private func beginUpdateChildViewControllers() {
        if currentIndex == potentialIndex {
            return
        }
        /// 开始切换
        beginTransitionChildViewController(fromIndex: currentIndex, toIndex: potentialIndex)
    }
    
    /// 结束更新
    private func endUpdateChildViewControllers() {
        resetCurrentState()
        endTransitionChildViewController(fromIndex: lastIndex, toIndex: potentialIndex)
    }
    
    /// 开始切换子控制器
    ///
    /// - Parameters:
    ///   - fromIndex: fromIndex
    ///   - toIndex: toIndex
    private func beginTransitionChildViewController(fromIndex: Int, toIndex: Int) {
        guard let newController = addChildViewContoller(at: toIndex),
            let oldController = childViewController(at: fromIndex) else { return }
        /// oldController消失, newController出现
        oldController.beginAppearanceTransition(false, animated: true)
        newController.beginAppearanceTransition(true, animated: true)
        /// 代理回调
        delegate?.pageContainer?(self, willTransition: oldController, toVC: newController)
    }
    
    /// 结束切换子控制器
    ///
    /// - Parameters:
    ///   - fromIndex: fromIndex
    ///   - toIndex: toIndex
    private func endTransitionChildViewController(fromIndex: Int, toIndex: Int) {
        guard let oldController = childViewController(at: fromIndex),
            let newController = childViewController(at: toIndex) else { return }
        if potentialIndex == currentIndex { /// 已切换
            oldController.endAppearanceTransition()
            newController.endAppearanceTransition()
            /// 代理回调
            delegate?.pageContainer?(self, didFinishedTransition: oldController, toVC: newController)
            delegate?.pageContainer?(self, didSelected: currentIndex)
        } else {  /// 未切换
            oldController.beginAppearanceTransition(true, animated: true)
            oldController.endAppearanceTransition()
            newController.beginAppearanceTransition(false, animated: true)
            newController.endAppearanceTransition()
            /// 代理回调
            delegate?.pageContainer?(self, didCancelledTransition: oldController, toVC: newController)
        }
    }
    
    /// 自定义scrollView的滚动动画
    ///
    /// - Parameters:
    ///   - fromIndex: fromIndex
    ///   - toIndex: toIndex
    private func customScrollAnimation(fromIndex: Int, toIndex: Int) {
        guard let oldController = childViewController(at: fromIndex) else { return }
        let oldViewFrame = oldController.view.frame
        var nearestIndex: Int
        if fromIndex > toIndex {
            nearestIndex = toIndex + 1
        } else {
            nearestIndex = toIndex - 1
        }
        /// 将当前控制器的view，移动到toIndex的旁边
        scrollView.contentOffset = CGPoint(x: CGFloat(nearestIndex) * scrollView.bounds.width, y: 0)
        oldController.view.frame.origin = CGPoint(x: CGFloat(nearestIndex) * scrollView.bounds.width, y: 0)
        /// 将其置于最上层
        scrollView.bringSubviewToFront(oldController.view)
        UIView.animate(withDuration: 0.25, animations: {
            self.scrollView.contentOffset = CGPoint(x: CGFloat(toIndex) * self.scrollView.bounds.width, y: 0)
        }) { (_) in
            oldController.view.frame = oldViewFrame
            self.endUpdateChildViewControllers()
        }
    }
}

// MARK: -  Public Methods
extension HXPageContainer {
    
    /// 重新加载数据
    func reloadData(_ reloadType: HXpageContainerReloadType = .all) {
        clearCaches(reloadType)
        reloadChildViewControllers(shouldForwardAppearance: true)
    }
    
    /// 重新设置当前页
    func setCurrentIndex(_ index: Int, animated: Bool) {
        /// 如果还没加载成功，说明是设置默认index
        if !isViewLoaded {
            currentIndex = index
            return
        }
        /// 如果index越界或index等于currentIndex，不处理
        if index < 0 || index >= numberOfChildViewControllers() || currentIndex == index {
            return
        }
        potentialIndex = index
        beginUpdateChildViewControllers()
        if !animated { /// 如果不执行滚动动画
            scrollView.contentOffset = CGPoint(x: CGFloat(index) * scrollView.bounds.width, y: 0)
            endUpdateChildViewControllers()
        } else {
            /// 自定义滚动动画
            customScrollAnimation(fromIndex: currentIndex, toIndex: potentialIndex)
        }
    }
    
}

// MARK: -  UIScrollViewDelegate
extension HXPageContainer: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        /// 如果不是拖动的，不做处理
        if !scrollView.isTracking && !scrollView.isDecelerating {
            return
        }
        let diffX = scrollView.contentOffset.x - lastOffsetX
        let percent = abs(diffX / scrollView.bounds.width)
        /// 滑动状态回调
        delegate?.pageContainer?(self, dragging: currentIndex, toIndex: potentialIndex, percent: percent)
        if diffX > 0 { /// 向左
            if !hasProcessAppearance || potentialIndex != currentIndex + 1 {
                hasProcessAppearance = true
                /// 如果已经向右滑动过又向左滑动
                if potentialIndex == currentIndex - 1 {
                    endTransitionChildViewController(fromIndex: currentIndex, toIndex: potentialIndex)
                }
                potentialIndex = currentIndex + 1
                beginUpdateChildViewControllers()
            }
        } else if diffX < 0 { /// 向右
            if !hasProcessAppearance || potentialIndex != currentIndex - 1 {
                hasProcessAppearance = true
                /// 如果已经向左滑动过又向右滑动
                if potentialIndex == currentIndex + 1 {
                    endTransitionChildViewController(fromIndex: currentIndex, toIndex: potentialIndex)
                }
                potentialIndex = currentIndex - 1
                beginUpdateChildViewControllers()
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if hasProcessAppearance {
            endUpdateChildViewControllers()
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        endUpdateChildViewControllers()
    }
    
}
