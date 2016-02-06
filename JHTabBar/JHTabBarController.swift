//
//  JHTabBarController.swift
//  JHTabBar
//
//  Created by Johannes H on 03.02.2016.
//  Copyright © 2016 Johannes Harestad. All rights reserved.
//

import UIKit

public class JHTabBarController: UITabBarController {
    
    var marker: UIView!
    var markerLeftConstraint: NSLayoutConstraint!
    var markerTopConstraint: NSLayoutConstraint!
    
    let markerHeight = 6
    let markerWidth = 65
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        print("👍 Yup! ✌️")
        
        initMarker()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "recreateMarkerDueToOrientationChange", name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    override public func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        guard let index = tabBar.items?.indexOf(item) else {
            return
        }
        
        guard let button = tabBarButtonAtIndex(index) else {
            return
        }
        
        positionMarkerAtButton(button)
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        positionMarkerAtSelectedButtonWithoutAnimation()
        setMarkerMask()
    }
    
    func tabBarButtonAtIndex(index: Int) -> UIView? {
        var buttons: [UIView] = []
        
        for subview in tabBar.subviews {
            if subview.isKindOfClass(UIControl) && subview.respondsToSelector("frame") {
                buttons.append(subview)
            }
        }
        
        if buttons.count == 0 {
            return nil
        }
        
        buttons.sortInPlace { (a, b) -> Bool in
            a.frame.origin.x < b.frame.origin.x
        }
        
        if index < buttons.count {
            return buttons[index]
        } else {
            // we return the last visible button
            return buttons.last!
        }
    }
    
    func initMarker() {
        marker?.removeFromSuperview()
        
        marker = UIView()
        marker.translatesAutoresizingMaskIntoConstraints = false
        marker.backgroundColor = UIColor.blackColor()
        
        /*
        marker.layer.borderColor = UIColor.redColor().CGColor
        marker.layer.borderWidth = 1
        */
        
        view.addSubview(marker)
        
        initMarkerSizeConstraints()
        initMarkerPositionConstraints()
    }
    
    func initMarkerSizeConstraints() {
        marker.addConstraint(NSLayoutConstraint(
            item: marker,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 1.0,
            constant: CGFloat(markerWidth)))
        
        marker.addConstraint(NSLayoutConstraint(
            item: marker,
            attribute: NSLayoutAttribute.Height,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 1.0,
            constant: CGFloat(markerHeight)))
    }
    
    func initMarkerPositionConstraints() {
        markerLeftConstraint = NSLayoutConstraint(
            item: marker,
            attribute: NSLayoutAttribute.Left,
            relatedBy: NSLayoutRelation.Equal,
            toItem: view,
            attribute: NSLayoutAttribute.Left,
            multiplier: 1.0,
            constant: 0)
        
        view.addConstraint(markerLeftConstraint)
        
        markerTopConstraint = NSLayoutConstraint(
            item: marker,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal,
            toItem: view,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1.0,
            constant: 0)
        
        view.addConstraint(markerTopConstraint)
    }
    
    func positionMarkerAtSelectedButtonWithoutAnimation() {
        guard let selectedItem = tabBar.selectedItem else {
            return
        }
        
        guard let index = tabBar.items?.indexOf(selectedItem) else {
            return
        }
        
        guard let button = tabBarButtonAtIndex(index) else {
            return
        }
        
        positionMarkerAtButton(button, withAnimation: false)
    }
    
    func positionMarkerAtButton(button: UIView, withAnimation animation: Bool = true) {
        let pointInButton = CGPoint(x: CGRectGetWidth(button.frame) / 2 - CGFloat(markerWidth / 2), y: 0)
        let pointInTabBar = button.convertPoint(pointInButton, toView: view)
        
        markerLeftConstraint.constant = pointInTabBar.x
        markerTopConstraint.constant = pointInTabBar.y - 1 //because of the hairline on the TabBar
        
        view.setNeedsUpdateConstraints()
        
        if animation {
            UIView.animateWithDuration(0.3, animations: { [unowned self] in
                self.view.layoutIfNeeded()
            })
        } else {
            view.layoutIfNeeded()
        }
    }
    
    func recreateMarkerDueToOrientationChange() {
        initMarker()
        
        positionMarkerAtSelectedButtonWithoutAnimation()
    }
    
    func setMarkerMask() {
        /*let path = UIBezierPath(roundedRect: marker.bounds, byRoundingCorners: [.BottomLeft, .BottomRight], cornerRadii: CGSize(width: 2, height: 2))*/
        
        let path = createBezierPath(CGSize(width: markerWidth, height: markerHeight))
        
        let mask = CAShapeLayer()
        mask.path = path.CGPath
        marker.layer.mask = mask
    }
    
    func createBezierPath(forSizedRect: CGSize) -> UIBezierPath {
        let x10 = forSizedRect.width * 10 / 100
        let x20 = forSizedRect.width * 20 / 100
        let x25 = forSizedRect.width * 25 / 100
        let x75 = forSizedRect.width * 75 / 100
        let x80 = forSizedRect.width * 80 / 100
        let x90 = forSizedRect.width * 90 / 100
        
        let path = UIBezierPath()
        
        path.moveToPoint(CGPoint(x: 0, y: 0))
        
        path.addLineToPoint(CGPoint(x: forSizedRect.width, y: 0))
        
        path.addCurveToPoint(CGPoint(x: x75, y: forSizedRect.height), controlPoint1: CGPoint(x: x90, y: forSizedRect.height), controlPoint2: CGPoint(x: x80, y: forSizedRect.height))
        
        path.addLineToPoint(CGPoint(x: x25, y: forSizedRect.height))
        
        path.addCurveToPoint(CGPoint(x: 0, y: 0), controlPoint1: CGPoint(x: x20, y: forSizedRect.height), controlPoint2: CGPoint(x: x10, y: forSizedRect.height))
        
        path.closePath()
        
        return path
    }
}
