//
//  TitleView.swift
//  PageView
//
//  Created by 王亚威 on 2023/6/25.
//

import UIKit

protocol TitleViewProtocol: NSObjectProtocol {
    func titleView(titleView: TitleView, fromIndex: Int, targetIndex: Int)
}

class TitleView: UIView {
    
    weak var deleagte: TitleViewProtocol?
    private var titles: [String]
    private var style: TitleStyle
    private var titleLabels = [UILabel]()
    private var currentIndex = 0
    
    private lazy var scrollView: UIScrollView = {
        let v = UIScrollView()
        v.showsHorizontalScrollIndicator = false
        v.frame = self.bounds
        return v
    }()
    
    private lazy var bottomLine: UIView = {
        let v = UIView()
        v.backgroundColor = style.BottomLineColor
        v.frame.size.height = style.BottomLineH
        v.frame.origin.y = self.bounds.height - style.BottomLineH
        return v
    }()
    
    init(frame: CGRect, titles: [String], style: TitleStyle) {
        self.titles = titles
        self.style = style
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TitleView {
    
    private func setupUI() {
        // 1.添加scrollView
        addSubview(scrollView)
        
        // 2.设置所有的标题label
        setupTitleLabels()
        
        // 3.设置所有标题label的frame
        setupTitleLabelFrame()
        
        // 4.添加底部滚动条
        if style.isShowBottomLine {
            setupBottomLine()
        }
    }
    
    private func setupTitleLabels() {
        for (index , title) in titles.enumerated() {
            let label = UILabel()
            label.tag = index
            label.text = title
            label.textColor = index == 0 ? style.selectColor : style.normalColor
          
            label.textAlignment = .center
            label.font = style.font
            scrollView.addSubview(label)
            titleLabels.append(label)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(titleLabelClicked(_ :)))
            label.addGestureRecognizer(tap)
            label.isUserInteractionEnabled = true
        }
    }
    
    private func setupTitleLabelFrame() {
        let count = titleLabels.count
        let h: CGFloat = bounds.height
        let y: CGFloat = 0
        for (i, label) in titleLabels.enumerated() {
            var x: CGFloat = 0
            var w: CGFloat = 0
            if style.isScrollEnable {
                w = (titles[i] as NSString).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: style.titleHeight), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: style.font], context: nil).width
                if i == 0 {
                    x = style.itemMargin*0.5
                    if style.isShowBottomLine {
                        bottomLine.frame.origin.x = x
                        bottomLine.frame.size.width = w
                    }
                } else {
                    x = titleLabels[i - 1].frame.maxX + style.itemMargin
                }
            } else {
                w = bounds.width / CGFloat(count)
                x = CGFloat(i) * w
                if i == 0 && style.isShowBottomLine {
                    bottomLine.frame.origin.x = 0
                    bottomLine.frame.size.width = w
                }
            }
            label.frame = CGRect.init(x: x, y: y, width: w, height: h)
            // 放大的代码
            if i == 0 {
                let scale = style.isNeedScale ? style.scaleRange : 1.0
                label.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        }

        let minContentSizeW = max(titleLabels.last!.frame.maxX + style.itemMargin*0.5, scrollView.bounds.size.width)
        scrollView.contentSize = style.isScrollEnable ? CGSize(width: minContentSizeW, height: 0) : scrollView.bounds.size
    }
    
    private func setupBottomLine() {
        scrollView.addSubview(bottomLine)
        bottomLine.frame = titleLabels.first!.frame
        bottomLine.frame.size.height = style.BottomLineH
        bottomLine.frame.origin.y = bounds.height - style.BottomLineH
    }
    
    @objc private func titleLabelClicked(_ tap: UITapGestureRecognizer) {
        // 1.获取当前label
        guard let currentLabel = tap.view as? UILabel else { return }
        
        // 2.获取之前选中的label
        let oldLabel = titleLabels[currentIndex]
        
        // 3.设置颜色
        oldLabel.textColor = style.normalColor
        currentLabel.textColor = style.selectColor
        
        // 4.通知代理
        deleagte?.titleView(titleView: self, fromIndex: currentIndex, targetIndex: currentLabel.tag)
        
        // 5.保存最新的Label的下标值
        currentIndex = currentLabel.tag

        // 6.居中显示
        contentViewDidEndScroll()

        // 7.调整title缩放
        if style.isNeedScale {
            UIView.animate(withDuration: 0.15) {
                oldLabel.transform = CGAffineTransform.identity
                currentLabel.transform = CGAffineTransform(scaleX: self.style.scaleRange, y: self.style.scaleRange)
            }
        }
        
        // 8.调整bottomLine
        if self.style.isShowBottomLine {
            UIView.animate(withDuration: 0.15) {
                self.bottomLine.frame.origin.x = currentLabel.frame.origin.x
                self.bottomLine.frame.size.width = currentLabel.frame.size.width
            }
        }
    }
    
    private func contentViewDidEndScroll() {
      
        // 1.如果是不需要滚动,则不调整中间位置
        guard style.isScrollEnable else { return }
        
        // 2.获取目标label
        let targetLabel = titleLabels[currentIndex]
        
        // 3.计算和中间位置的偏移量
        var offsetX: CGFloat = targetLabel.center.x - bounds.width * 0.5
        if offsetX < 0 {
            offsetX = 0
        }
        if offsetX > scrollView.contentSize.width - scrollView.bounds.width {
            offsetX = scrollView.contentSize.width - scrollView.bounds.width
        }
        
        // 4.滚动UIScrollView
        scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
    }
    
}

extension TitleView {
    
   // MARK: - 对外暴漏的方法
   public func setTitle(progress: CGFloat, sourceIndex: Int, targetIndex: Int) {
        let count = titleLabels.count
        guard sourceIndex >= 0, sourceIndex < count,
                targetIndex >= 0, targetIndex < count else {
                    fatalError("TitleView:请传入合法的下标")
                }
        
        // 0.获取之前被选中的label
        let sourceLabel = titleLabels[sourceIndex]
        // 1.获取当前被选中的label
        let targetLabel = titleLabels[targetIndex]
        
        // 2.颜色渐变
        // 2.1取出变化的范围
        let deltaRGB = UIColor.getRGBDelta(style.selectColor, style.normalColor)
        let normalRGB = style.normalColor.getRGB()
        let selectRGB = style.selectColor.getRGB()
        
        // 2.2变化sourceLabel
        sourceLabel.textColor = UIColor(r: selectRGB.0 - deltaRGB.0 * progress, g: selectRGB.1 - deltaRGB.1 * progress, b: selectRGB.2 - deltaRGB.2 * progress)
        
        // 2.3变化targetLabel
        targetLabel.textColor = UIColor(r: normalRGB.0 + deltaRGB.0 * progress, g:  normalRGB.1 + deltaRGB.1 * progress, b:  normalRGB.2 + deltaRGB.2 * progress)
        
        // 3.记录最新的index
        currentIndex = targetIndex
        
        // 4.调整底部线,计算滚动的范围差
        if style.isShowBottomLine {
            let detalX = targetLabel.frame.origin.x - sourceLabel.frame.origin.x
            let detalW = targetLabel.frame.size.width - sourceLabel.frame.size.width
            bottomLine.frame.origin.x = sourceLabel.frame.origin.x + detalX * progress
            bottomLine.frame.size.width = sourceLabel.frame.size.width + detalW * progress
        }
        
        // 5.调整title缩放
        if style.isNeedScale {
            let detalScale = (style.scaleRange - 1.0)*progress
            UIView.animate(withDuration: 0.25) {
                sourceLabel.transform = CGAffineTransform(scaleX: self.style.scaleRange - detalScale, y: self.style.scaleRange - detalScale)
                targetLabel.transform = CGAffineTransform(scaleX: 1.0 + detalScale, y: 1.0 + detalScale)
            }
        }
    }
}
