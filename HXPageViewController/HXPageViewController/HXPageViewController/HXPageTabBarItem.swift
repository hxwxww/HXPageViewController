//
//  HXPageTabBarItem.swift
//  HXPageViewController
//
//  Created by HongXiangWen on 2019/1/9.
//  Copyright © 2019年 WHX. All rights reserved.
//

import UIKit

// MARK: -  工具函数
struct HXPageTabBarUtil {
    
    /// 计算中间值
    ///
    /// - Parameters:
    ///   - fromFont: fromValue
    ///   - toFont: toValue
    ///   - percent: percent
    /// - Returns: interpolationValue
    static func interpolationValue(fromValue: CGFloat, toValue: CGFloat, percent: CGFloat) -> CGFloat {
        let newPercent = min(max(0, percent), 1)
        return fromValue + (toValue - fromValue) * newPercent
    }
    
    /// 计算字体
    ///
    /// - Parameters:
    ///   - fromFont: fromFont
    ///   - toFont: toFont
    ///   - percent: percent
    /// - Returns: interpolationFont
    static func interpolationFont(fromFont: UIFont, toFont: UIFont, percent: CGFloat) -> UIFont {
        let fromFontSize = fromFont.pointSize
        let fromFontDescriptor = fromFont.fontDescriptor
        let toFontSize = toFont.pointSize
        let interpolationFontSize = interpolationValue(fromValue: fromFontSize, toValue: toFontSize, percent: percent)
        return UIFont(descriptor: fromFontDescriptor, size: interpolationFontSize)
    }
    
    /// 计算颜色
    ///
    /// - Parameters:
    ///   - fromColor: fromColor
    ///   - toColor: toColor
    ///   - percent: percent
    /// - Returns: interpolationColor
    static func interpolationColor(fromColor: UIColor, toColor: UIColor, percent: CGFloat) -> UIColor {
        /// fromColor的rgb
        var fromRed: CGFloat = 0
        var fromGreen: CGFloat = 0
        var fromBlue: CGFloat = 0
        var fromAlpha: CGFloat = 0
        fromColor.getRed(&fromRed, green: &fromGreen, blue: &fromBlue, alpha: &fromAlpha)
        /// toColor的rgb
        var toRed: CGFloat = 0
        var toGreen: CGFloat = 0
        var toBlue: CGFloat = 0
        var toAlpha: CGFloat = 0
        toColor.getRed(&toRed, green: &toGreen, blue: &toBlue, alpha: &toAlpha)
        /// 计算rgb
        let red = interpolationValue(fromValue: fromRed, toValue: toRed, percent: percent)
        let green = interpolationValue(fromValue: fromGreen, toValue: toGreen, percent: percent)
        let blue = interpolationValue(fromValue: fromBlue, toValue: toBlue, percent: percent)
        let alpha = interpolationValue(fromValue: fromAlpha, toValue: toAlpha, percent: percent)
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /// 计算宽度
    ///
    /// - Parameters:
    ///   - text: 字符串
    ///   - font: 字体
    /// - Returns: 宽度
    static func stringWidth(with text: String, font: UIFont) -> CGFloat {
        let attributes = [NSAttributedString.Key.font: font]
        let width = (text as NSString).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 30), options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size.width
        return width
    }
    
}

// MARK: -  item数据模型
struct HXPageTabBarItemModel {
    
    let title: String
    let titleFont: UIFont
    let titleHighlightedFont: UIFont
    let titleColor: UIColor
    let titleHighlightedColor: UIColor
    let itemWidth: CGFloat
    var isSelected: Bool
    
}

// MARK: -  HXPageTabBarItem
class HXPageTabBarItem: UICollectionViewCell {
    
    /// 重用标识
    static var reuseID: String {
        return "\(HXPageTabBarItem.self)"
    }
    
    // MARK: -  Properties
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: CGRect.zero)
        titleLabel.textAlignment = .center
        return titleLabel
    }()
    
    // MARK: -  init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        contentView.addSubview(titleLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.center = contentView.center
    }
    
    /// 配置cell
    ///
    /// - Parameter itemModel: model
    func configItem(itemModel: HXPageTabBarItemModel) {
        titleLabel.text = itemModel.title
        if itemModel.isSelected {
            titleLabel.font = itemModel.titleHighlightedFont
            titleLabel.textColor = itemModel.titleHighlightedColor
        } else {
            titleLabel.font = itemModel.titleFont
            titleLabel.textColor = itemModel.titleColor
        }
        titleLabel.sizeToFit()
        setNeedsLayout()
    }
    
}
