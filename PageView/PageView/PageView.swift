//
//  PageView.swift
//  PageView
//
//  Created by 王亚威 on 2023/6/25.
//

import UIKit

class PageView: UIView {

    private var titles: [String]
    private var childrenVc: [UIViewController]
    private var parsentVc: UIViewController
    private var titleStyle: TitleStyle
    
    private var titleView: TitleView!
    private var contentView: ContentView!

    init(frame: CGRect, titles: [String], childrenVc: [UIViewController], parsentVc: UIViewController, titleStyle: TitleStyle) {
        self.titles = titles
        self.childrenVc = childrenVc
        self.parsentVc = parsentVc
        self.titleStyle = titleStyle
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - 对外暴漏的方法
extension PageView {
    
    public func setSelectIndex(_ index: Int) {
        guard index >= 0, index < childrenVc.count else {
            fatalError("PageView:请传入合法的下标")
        }
        titleView.setTitle(progress: 1, sourceIndex: 0, targetIndex: index)
        contentView.setCurrentIndex(fromIndex: 0, targetIndex: index)
    }
}

extension PageView {
    
    fileprivate func setupUI() {
        titleView = TitleView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: titleStyle.titleHeight), titles: titles, style: titleStyle)
        titleView.deleagte = self
        titleView.backgroundColor = UIColor.orange
        addSubview(titleView)
        
        contentView = ContentView(frame: CGRect.init(x: 0, y: titleView.frame.maxY, width: self.bounds.width, height: self.bounds.height - titleView.bounds.height), childrenVc: childrenVc, parsentVc: parsentVc)
        contentView.delegate = self
        contentView.backgroundColor = UIColor.lightGray
        addSubview(contentView)
    }
    
}

// MARK: - TitleViewProtocol

extension PageView: TitleViewProtocol {
    
    func titleView(titleView: TitleView, fromIndex: Int, targetIndex: Int) {
        contentView.setCurrentIndex(fromIndex: fromIndex, targetIndex: targetIndex)
    }
}

// MARK: - ContentViewProtocol

extension PageView: ContentViewProtocol {
 
    func contentViewDidScroll(contentView: ContentView, sourceIndex: Int, targetIndex: Int, progress: CGFloat) {
        titleView.setTitle(progress: progress, sourceIndex: sourceIndex, targetIndex: targetIndex)
    }
}


