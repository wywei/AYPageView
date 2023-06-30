//
//  PageCollectionViewFlowLayout.swift
//  PageView
//
//  Created by 王亚威 on 2023/6/29.
//

import UIKit

class PageCollectionViewFlowLayout: UICollectionViewFlowLayout {

    // 默认列数
    public var cols: Int = 4
    // 默认行数
    public var rows: Int = 2
    
    private var attrs = [UICollectionViewLayoutAttributes]()
    private var maxWidth: CGFloat = 0
    
    // MARK: - 准备布局
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }
        let sectionCount = collectionView.numberOfSections
        let collectionViewW: CGFloat = collectionView.bounds.width
        let collectionViewH: CGFloat = collectionView.bounds.height

        let itemW: CGFloat = (collectionViewW - sectionInset.left - sectionInset.right - CGFloat(cols-1)*minimumInteritemSpacing)/CGFloat(cols)
        let itemH: CGFloat = (collectionViewH - sectionInset.top - sectionInset.bottom - CGFloat(rows-1)*minimumLineSpacing)/CGFloat(rows)
        var prePageCount = 0
        for section in 0..<sectionCount {
            let itemCount = collectionView.numberOfItems(inSection: section)
            for index in 0..<itemCount {
                let indexPath = IndexPath(row: index, section: section)
                let attr = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                // 当前分区有几页
                let page = index/(cols*rows)
                // item在当前页的下标
                let index = index%(cols*rows)
                let x: CGFloat = CGFloat(prePageCount + page)*collectionViewW + sectionInset.left + CGFloat(index%cols) * (itemW + minimumInteritemSpacing)
                let y: CGFloat = sectionInset.top + (itemH + minimumLineSpacing) * CGFloat((index/cols))
                attr.frame = CGRect(x: x, y: y, width: itemW, height: itemH)
                attrs.append(attr)
            }
            // 累计所有分区的总页数
            prePageCount += (itemCount - 1)/(cols*rows) + 1
        }
        maxWidth = CGFloat(prePageCount) * collectionViewW
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attrs
    }

}

extension PageCollectionViewFlowLayout {
    override var collectionViewContentSize: CGSize {
        return CGSize(width: maxWidth, height: 0)
    }
}
