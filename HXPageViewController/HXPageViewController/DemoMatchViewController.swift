//
//  DemoMatchViewController.swift
//  HXPageViewController
//
//  Created by HongXiangWen on 2019/1/10.
//  Copyright © 2019年 WHX. All rights reserved.
//

import UIKit

class DemoMatchViewController: UIViewController {

    private let titles = ["大菠萝", "苹果","芒果", "梨", "香蕉","橘子", "哈密瓜", "西瓜", "葡萄", "橙子", "柚子"]

    private lazy var pageContainer: HXPageContainer = {
        let pageContainer = HXPageContainer()
        pageContainer.dataSource = self
        pageContainer.delegate = self
        return pageContainer
    }()
    
    private lazy var pageTabBar: HXPageTabBar = {
        let pageTabBar = HXPageTabBar(frame: CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height + 44, width: UIScreen.main.bounds.width, height: 50))
        pageTabBar.dataSource = self
        pageTabBar.delegate = self
        return pageTabBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChild(pageContainer)
        pageContainer.didMove(toParent: self)
        view.addSubview(pageContainer.view)
        pageTabBar.contentScrollView = pageContainer.scrollView
        view.addSubview(pageTabBar)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let navigationHeight = UIApplication.shared.statusBarFrame.height + 44
        pageTabBar.frame = CGRect(x: 0, y: navigationHeight, width: UIScreen.main.bounds.width, height: 50)
        pageContainer.view.frame = CGRect(x: 0, y: navigationHeight + 50, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - navigationHeight - 50 )
    }
    
    @IBAction func reload(_ sender: Any) {
        pageTabBar.setSelectedIndex(5, shouldHandleContentScrollView: true)
    }
    
}

// MARK: -  HXPageContainerDelegate, HXPageContainerDataSource
extension DemoMatchViewController: HXPageContainerDelegate, HXPageContainerDataSource {
    
    func numberOfChildViewControllers(in pageContainer: HXPageContainer) -> Int {
        return titles.count
    }
    
    func pageContainer(_ pageContainer: HXPageContainer, childViewContollerAt index: Int) -> UIViewController {
        let detailVC = DetailViewController(nibName: "DetailViewController", bundle: nil)
        detailVC.text = titles[index]
        return detailVC
    }
    
    func defaultCurrentIndex(in pageContainer: HXPageContainer) -> Int {
        return 5
    }

}

// MARK: -  HXPageContainerDelegate, HXPageContainerDataSource
extension DemoMatchViewController: HXPageTabBarDataSource, HXPageTabBarDelegate {
    
    func numberOfItems(in pageTabBar: HXPageTabBar) -> Int {
        return titles.count
    }
    
    func pageTabBar(_ pageTabBar: HXPageTabBar, titleForItemAt index: Int) -> String {
        return titles[index]
    }
    
    func defaultSelectedIndex(in pageTabBar: HXPageTabBar) -> Int {
        return 5
    }
    
}
