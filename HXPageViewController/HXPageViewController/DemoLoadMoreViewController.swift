//
//  DemoLoadMoreViewController.swift
//  HXPageViewController
//
//  Created by HongXiangWen on 2019/1/8.
//  Copyright © 2019年 WHX. All rights reserved.
//

import UIKit

class DemoLoadMoreViewController: UIViewController {

    private var count: Int = 5
    private var isLoading: Bool = false
    
    private lazy var pageContainer: HXPageContainer = {
        let pageContainer = HXPageContainer()
        pageContainer.dataSource = self
        pageContainer.delegate = self
        return pageContainer
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Index\(1)"
        addChild(pageContainer)
        pageContainer.didMove(toParent: self)
        view.addSubview(pageContainer.view)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let navigationHeight = UIApplication.shared.statusBarFrame.height + 44
        pageContainer.view.frame = CGRect(x: 0, y: navigationHeight, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - navigationHeight)
    }

}

// MARK: -  HXPageContainerDelegate, HXPageContainerDataSource
extension DemoLoadMoreViewController: HXPageContainerDelegate, HXPageContainerDataSource {
    
    func numberOfChildViewControllers(in pageContainer: HXPageContainer) -> Int {
        return count
    }
    
    func pageContainer(_ pageContainer: HXPageContainer, childViewContollerAt index: Int) -> UIViewController {
        let detailVC = DetailViewController(nibName: "DetailViewController", bundle: nil)
        detailVC.text = "Index\(index)"
        return detailVC
    }
    
    func defaultCurrentIndex(in pageContainer: HXPageContainer) -> Int {
        return 1
    }
    
    func pageContainer(_ pageContainer: HXPageContainer, didSelected index: Int) {
        title = "Index\(index)"
        if count - index < 3 && count < 15 && !isLoading {
            isLoading = true
            print("加载中...")
            /// 模拟网络请求
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.count += 5
                self.pageContainer.reloadData(.notReload)
                print("加载完成")
                self.isLoading = false
            }
        }
    }
    
}
