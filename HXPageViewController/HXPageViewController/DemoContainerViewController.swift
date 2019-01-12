//
//  DemoContainerViewController.swift
//  HXPageViewController
//
//  Created by HongXiangWen on 2019/1/7.
//  Copyright © 2019年 WHX. All rights reserved.
//

import UIKit

class DemoContainerViewController: UIViewController {

    private let titles = ["大菠萝", "苹果","芒果", "梨", "香蕉","橘子", "哈密瓜", "西瓜", "葡萄", "橙子", "柚子"]
    
    private lazy var pageContainer: HXPageContainer = {
        let pageContainer = HXPageContainer()
        pageContainer.dataSource = self
        pageContainer.delegate = self
        return pageContainer
    }()
    
    @IBOutlet weak var segment: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segment.selectedSegmentIndex = 1
        pageContainer.setCurrentIndex(1, animated: false)
        addChild(pageContainer)
        pageContainer.didMove(toParent: self)
        view.addSubview(pageContainer.view)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let navigationHeight = UIApplication.shared.statusBarFrame.height + 44
        pageContainer.view.frame = CGRect(x: 0, y: navigationHeight, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - navigationHeight)
    }

    @IBAction func segmentDidChanged(_ sender: UISegmentedControl) {
        pageContainer.setCurrentIndex(sender.selectedSegmentIndex, animated: true)
    }
    
    @IBAction func reloadAction(_ sender: Any) {
        let randomTitles = randomElements()
        segment.removeAllSegments()
        for randomTitle in randomTitles {
            segment.insertSegment(withTitle: randomTitle, at: 0, animated: false)
        }
        segment.selectedSegmentIndex = min(randomTitles.count - 1, pageContainer.currentIndex)
        segment.sizeToFit()
        segment.layoutIfNeeded()
        pageContainer.reloadData()
    }
    
    private func randomElements() -> [String] {
        var randomElements: [String] = []
        let randomCount = Int(arc4random() % 3) + 2
        var copyElements = titles
        for _ in 0 ..< randomCount {
            // 如果copyElements的元素取光了
            if copyElements.isEmpty {
                break
            }
            let randomIndex = Int(arc4random_uniform(UInt32(copyElements.count)))
            randomElements.append(copyElements[randomIndex])
            copyElements.remove(at: randomIndex)
        }
        return randomElements
    }
    
}

// MARK: -  HXPageContainerDelegate, HXPageContainerDataSource
extension DemoContainerViewController: HXPageContainerDelegate, HXPageContainerDataSource {
 
    func numberOfChildViewControllers(in pageContainer: HXPageContainer) -> Int {
        return segment.numberOfSegments
    }
    
    func pageContainer(_ pageContainer: HXPageContainer, childViewContollerAt index: Int) -> UIViewController {
        let detailVC = DetailViewController(nibName: "DetailViewController", bundle: nil)
        detailVC.text = segment.titleForSegment(at: index) ?? ""
        return detailVC
    }
    
    func pageContainer(_ pageContainer: HXPageContainer, willTransition fromVC: UIViewController, toVC: UIViewController) {
//        print("willTransition: \(pageContainer.currentIndex) fromVC: \(fromVC) toVC: \(toVC)")
    }
    
    func pageContainer(_ pageContainer: HXPageContainer, didFinishedTransition fromVC: UIViewController, toVC: UIViewController) {
//        print("didFinishedTransition: \(pageContainer.currentIndex) fromVC: \(fromVC) toVC: \(toVC)")
    }
    
    func pageContainer(_ pageContainer: HXPageContainer, didCancelledTransition fromVC: UIViewController, toVC: UIViewController) {
//        print("didCancelledTransition: \(pageContainer.currentIndex) fromVC: \(fromVC) toVC: \(toVC)")
    }
    
    func pageContainer(_ pageContainer: HXPageContainer, dragging fromIndex: Int, toIndex: Int, percent: CGFloat) {
//        print("dragging: \(pageContainer.currentIndex) fromIndex: \(fromIndex) toIndex: \(toIndex) percent: \(percent)")
    }
    
    func pageContainer(_ pageContainer: HXPageContainer, didSelected index: Int) {
        segment.selectedSegmentIndex = index
    }
    
}
