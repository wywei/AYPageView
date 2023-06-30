//
//  PageCollectionView.swift
//  PageView
//
//  Created by 王亚威 on 2023/6/29.
//

import UIKit

protocol PageCollectionViewDataSource: NSObjectProtocol {
    func numberOfSections(in pageCollectionView: PageCollectionView, collectionView: UICollectionView) -> Int
    func pageCollectionView(_ pageCollectionView: PageCollectionView, collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    func pageCollectionView(_ pageCollectionView: PageCollectionView, collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
}

class PageCollectionView: UIView {
    
    public weak var dataSource: PageCollectionViewDataSource?
    private var titles: [String]
    private var isTitleInTop: Bool
    private var layout: PageCollectionViewFlowLayout
    private var titleStyle: TitleStyle
    private var titleView: TitleView!
    private var collectionView: UICollectionView!
    private var pageControl: UIPageControl!
    private var sourceIndexPath = IndexPath.init(row: 0, section: 0)
    private var isForbidScrollDelegate: Bool = false
    
    init(frame: CGRect, titles: [String], isTitleInTop: Bool, titleStyle: TitleStyle, layout: PageCollectionViewFlowLayout) {
        self.titles = titles
        self.isTitleInTop = isTitleInTop
        self.titleStyle = titleStyle
        self.layout = layout
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension PageCollectionView {
    fileprivate func setupUI() {
        let superViewW: CGFloat = self.bounds.width
        let superViewH: CGFloat = self.bounds.height
        let pageControlH: CGFloat = 20

        let y: CGFloat = isTitleInTop ? 0 : superViewH - titleStyle.titleHeight
        titleView = TitleView(frame: CGRect(x: 0, y: y, width: superViewW, height: titleStyle.titleHeight), titles: titles, style: titleStyle)
        titleView.deleagte = self
        addSubview(titleView)
        titleView.backgroundColor = UIColor.randomColor()
        
        let collectionY: CGFloat = isTitleInTop ? titleStyle.titleHeight : 0
        collectionView = UICollectionView(frame: CGRect(x: 0, y: collectionY, width: superViewW, height: superViewH - titleStyle.titleHeight - pageControlH), collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.scrollsToTop = false
        collectionView.showsHorizontalScrollIndicator = false
        addSubview(collectionView)
        collectionView.backgroundColor = UIColor.randomColor()

        pageControl = UIPageControl()
        let pageControlY: CGFloat = isTitleInTop ? superViewH - pageControlH : superViewH - titleStyle.titleHeight - pageControlH
        pageControl.frame = CGRect(x: 0, y: pageControlY, width: superViewW, height: pageControlH)
        pageControl.numberOfPages = 3
        pageControl.currentPage = 0
        pageControl.isEnabled = false
        addSubview(pageControl)
        pageControl.backgroundColor = UIColor.randomColor()
    }

}

// MARK: - 对外提供的方法

extension PageCollectionView {
    
    public func register(cellClass: AnyClass , identifier: String)  {
        collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    public func register(nib: UINib , identifier: String) {
        collectionView.register(nib, forCellWithReuseIdentifier: identifier)
    }
    
}

// MARK: - UICollectionViewDataSource

extension PageCollectionView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource?.numberOfSections(in: self, collectionView: collectionView) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let itemCount = dataSource?.pageCollectionView(self, collectionView: collectionView, numberOfItemsInSection: section) ?? 0
        if section == 0 {
            pageControl.numberOfPages = (itemCount - 1)/(layout.cols*layout.rows) + 1
        }
        return itemCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dataSource!.pageCollectionView(self, collectionView: collectionView, cellForItemAt: indexPath)
        cell.backgroundColor = UIColor.randomColor()
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension PageCollectionView: UICollectionViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewEndScroll()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollViewEndScroll()
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollViewEndScroll()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isForbidScrollDelegate = false
    }
    
    private func scrollViewEndScroll() {
        // 取出indexpath
        guard let indexPath = collectionView.indexPathForItem(at: CGPoint(x:collectionView.contentOffset.x + layout.sectionInset.left + 1, y: layout.sectionInset.top + 1)) else { return }
     
        // 判断分组是否发生变化
        if sourceIndexPath.section != indexPath.section {
           let itemCount = dataSource?.pageCollectionView(self, collectionView: collectionView, numberOfItemsInSection: indexPath.section)
            pageControl.numberOfPages = (itemCount! - 1) / (layout.cols*layout.rows) + 1
            // 滚动UICollectionView时可以触发
            if !isForbidScrollDelegate {
                // 设置titleView的位置
                titleView.setTitle(progress: 1.0, sourceIndex: sourceIndexPath.section, targetIndex: indexPath.section)
            }
            // 保存最新的indexpath
            sourceIndexPath = indexPath
        }
        
        // 根据indexpath设置pageControl
        pageControl.currentPage = indexPath.item/(layout.cols*layout.rows)
    }
  
}

// MARK: - TitleViewProtocol

extension PageCollectionView: TitleViewProtocol {
    
    func titleView(titleView: TitleView, fromIndex: Int, targetIndex: Int) {
        isForbidScrollDelegate = true
        let indexPath = IndexPath(row: 0, section: targetIndex)
        collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
        scrollViewEndScroll()
    }
    
}
