//
//  TitleStyle.swift
//  PageView
//
//  Created by 王亚威 on 2023/6/25.
//

import UIKit

struct TitleStyle {

    // title的默认高度
    var titleHeight: CGFloat = 44
    
    // title的未选中时的颜色
    var normalColor: UIColor = UIColor(r: 0, g: 0, b: 0)
    // title的选中时的颜色
    var selectColor: UIColor = UIColor(r: 255, g: 0, b: 0)
    // title的字体
    var font: UIFont = UIFont.systemFont(ofSize: 13)
    
    // 是否是滚动的Title
    var isScrollEnable: Bool = false
    // 滚动title的字体间距
    var itemMargin: CGFloat = 20
    
    // 是否显示底部滚动条
    var isShowBottomLine: Bool = false
    // 底部滚动条高度
    var BottomLineH: CGFloat = 2
    // 底部滚动条颜色
    var BottomLineColor: UIColor = UIColor.purple
    
    // 是否需要缩放
    var isNeedScale: Bool = false
    var scaleRange: CGFloat = 1.3
    
    /// TODO
    /// 是否显示遮盖
    var isShowCover : Bool = false
    /// 遮盖背景颜色
    var coverBgColor : UIColor = UIColor.lightGray
    /// 文字&遮盖间隙
    var coverMargin : CGFloat = 5
    /// 遮盖的高度
    var coverH : CGFloat = 25
    /// 设置圆角大小
    var coverRadius : CGFloat = 12
    
}
