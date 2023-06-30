//
//  ContentView.swift
//  PageView
//
//  Created by 王亚威 on 2023/6/25.
//

import UIKit

@objc protocol ContentViewProtocol: NSObjectProtocol {
    @objc optional func contentViewDidEndScroll(contentView: ContentView)
    func contentViewDidScroll(contentView: ContentView, sourceIndex: Int, targetIndex: Int, progress: CGFloat)
}

class ContentView: UIView {

    public weak var delegate: ContentViewProtocol?
    public private(set) var childrenVc: [UIViewController]
    public private(set) var parsentVc: UIViewController
    // 是否禁止滚动代理方法执行
    private var isForbidScrollDelegate: Bool = false
    // 记录初始滑动的偏移值,用来判断滑动方向
    fileprivate var startOffsetx: CGFloat = 0
    // 记录当前显示内容的index
    private var currentIndex: Int = -999
    // 可能的下一页
    private var potentialIndex: Int = -999
    // 是否已经处理了子控制器的生命周期函数
    private var hasProcessAppearance: Bool = false

    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = bounds.size
        layout.scrollDirection = .horizontal
        
        let v = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        v.isPagingEnabled = true
        v.delegate = self
        v.dataSource = self
        v.scrollsToTop = false
        v.bounces = false
        v.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "reuse")
        return v
    }()
    
    init(frame: CGRect, childrenVc: [UIViewController], parsentVc: UIViewController) {
        self.childrenVc = childrenVc
        self.parsentVc = parsentVc
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension ContentView {
    
    fileprivate func setupUI() {
        addSubview(collectionView)
    }

}

extension ContentView: UICollectionViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        contentEndScroll()
        delegate?.contentViewDidEndScroll?(contentView: self)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            contentEndScroll()
            delegate?.contentViewDidEndScroll?(contentView: self)
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        delegate?.contentViewDidEndScroll?(contentView: self)
        hasProcessAppearance = false
    }
    
    func contentEndScroll() {
        guard !isForbidScrollDelegate else { return }
        hasProcessAppearance = false
        let targetIndex = Int(collectionView.contentOffset.x / collectionView.bounds.width)
        
        // 控制子控制器的生命周期
        if targetIndex == potentialIndex {//已切换
            let targetVc = childrenVc[targetIndex]
            let fromVc = childrenVc[currentIndex]
            fromVc.endAppearanceTransition()
            targetVc.endAppearanceTransition()
        } else {//未切换
            let potentialVc = childrenVc[potentialIndex]
            let fromVc = childrenVc[currentIndex]
            fromVc.beginAppearanceTransition(true, animated: true)
            potentialVc.beginAppearanceTransition(false, animated: true)
            potentialVc.endAppearanceTransition()
            fromVc.endAppearanceTransition()
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isForbidScrollDelegate = false
        startOffsetx = scrollView.contentOffset.x
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard startOffsetx != scrollView.contentOffset.x, !isForbidScrollDelegate else {
            return
        }
        var targetIndex = 0
        var progress: CGFloat = 0
        
        currentIndex = Int(startOffsetx / scrollView.bounds.width)
        if startOffsetx < scrollView.contentOffset.x { //左滑
            targetIndex = currentIndex + 1
            if targetIndex > childrenVc.count - 1 {
                targetIndex = childrenVc.count - 1
            }
            progress = (scrollView.contentOffset.x - startOffsetx)/scrollView.bounds.width
        } else {//右滑
            targetIndex = currentIndex - 1
            if targetIndex < 0 {
                targetIndex = 0
            }
            progress = (startOffsetx - scrollView.contentOffset.x)/scrollView.bounds.width
        }
        potentialIndex = targetIndex
        delegate?.contentViewDidScroll(contentView: self, sourceIndex: currentIndex, targetIndex: targetIndex, progress: progress)
        
        // 控制子控制器的生命周期
        if !hasProcessAppearance {
            hasProcessAppearance = true
            let currentVc = childrenVc[currentIndex]
            let targetVc = childrenVc[targetIndex]
            currentVc.beginAppearanceTransition(false, animated: true)
            targetVc.beginAppearanceTransition(true, animated: true)
        }
    }
}

extension ContentView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reuse", for: indexPath)
        let vc = childrenVc[indexPath.row]
        if !parsentVc.children.contains(vc) {
            addChildren(childVc: vc, superView: cell.contentView, index: indexPath.row)
        }
        return cell
    }

    func addChildren(childVc: UIViewController, superView: UIView, index: Int) {
        childVc.view.frame = CGRect(x: 0, y: 0, width: collectionView.bounds.width, height: collectionView.bounds.height)
        superView.addSubview(childVc.view)
        parsentVc.addChild(childVc)
        childVc.didMove(toParent: parsentVc)
//        if index == 0 && !isSettedDefaultIndex {
//            childVc.beginAppearanceTransition(true, animated: true)
//            childVc.endAppearanceTransition()
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return childrenVc.count
    }
}


extension ContentView {
    
    // MARK: - 对外暴漏的方法
    func setCurrentIndex(fromIndex: Int, targetIndex: Int) {
        isForbidScrollDelegate = true
        let count = childrenVc.count
        guard targetIndex < count, fromIndex < count else {
            fatalError("ContentView: 请传入合法的下标")
        }
        // 控制子控制器的生命周期
        if fromIndex != targetIndex {
            let targetVc = childrenVc[targetIndex]
            targetVc.beginAppearanceTransition(true, animated: true)
            if fromIndex >= 0 && fromIndex < count {
                let fromVc = childrenVc[fromIndex]
                fromVc.beginAppearanceTransition(false, animated: true)
                fromVc.endAppearanceTransition()
            }
            targetVc.endAppearanceTransition()
        }
        let indexPath = IndexPath(row: targetIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
    }
    
}
