//
//  ViewController.swift
//  PageView
//
//  Created by 王亚威 on 2023/6/25.
//

import UIKit

fileprivate let screenW: CGFloat = UIScreen.main.bounds.width
fileprivate let screenH: CGFloat = UIScreen.main.bounds.height

fileprivate let cellIdentifity = "cellIdentifity"


class ViewController: UIViewController {

    let titles = ["首页", "直播", "娱乐", "新闻"]
//    let titles = ["首页", "视频视频视频", "直播"]
    var pageView: PageView!

    var pageCollectionView: PageCollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "首页"
   
        var titleStyle = TitleStyle()
        titleStyle.isScrollEnable = true
        titleStyle.isShowBottomLine = true
        titleStyle.isNeedScale = true
        
//        pageView = PageView(frame: CGRect(x: 0, y: 64, width: self.view.bounds.width, height: self.view.bounds.height - 64), titles: titles, childrenVc: getChildrenVc(), parsentVc: self, titleStyle: titleStyle)
////        pageView.setSelectIndex(3)
//        view.addSubview(pageView)
        
        
        let layout = PageCollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.cols = 4
        layout.rows = 2

        pageCollectionView = PageCollectionView.init(frame: CGRect(x: 0, y: 64, width: screenW, height: screenH * 0.5), titles: titles, isTitleInTop: true, titleStyle: titleStyle, layout: layout)
        pageCollectionView.register(cellClass: UICollectionViewCell.self, identifier: cellIdentifity)
        pageCollectionView.dataSource = self
        view.addSubview(pageCollectionView)
    }
    
    func getChildrenVc() -> [UIViewController] {
        var vcs = [UIViewController]()
        let one = OneViewController()
        vcs.append(one)
        let two = TwoViewController()
        vcs.append(two)
        let three = ThreeViewController()
        vcs.append(three)
        let four = FourViewController()
        vcs.append(four)
        let five = FiveViewController()
        vcs.append(five)
        let six = SixViewController()
        vcs.append(six)
        return vcs
    }
    
    /// 设置false，手动控制子控制器的生命周期
    open override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return false
    }

  
}


extension ViewController: PageCollectionViewDataSource {
    func numberOfSections(in pageCollectionView: PageCollectionView, collectionView: UICollectionView) -> Int {
        return 4
    }
    
    func pageCollectionView(_ pageCollectionView: PageCollectionView, collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 10
        }
        return 5
    }
    
    func pageCollectionView(_ pageCollectionView: PageCollectionView, collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifity, for: indexPath)
        cell.backgroundColor = UIColor.randomColor()
        return cell
    }
  
}
