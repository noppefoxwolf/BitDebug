//
//  BitDebug.swift
//  BitDebug
//
//  Created by Tomoya Hirano on 2016/05/28.
//  Copyright © 2016年 CocoaPods. All rights reserved.
//

import UIKit

public final class BitDebug {
  private static let instance = BitDebug()
  private let bitDebugView = BitDebugView()
  private let nc = NSNotificationCenter.defaultCenter()
  private var isShowing = false
  public class func show() {
    BitDebug.instance.isShowing = true
    BitDebug.instance.bitDebugView.removeFromSuperview()
    UIApplication.sharedApplication().keyWindow?.addSubview(BitDebug.instance.bitDebugView)
  }
  
  public class func hide() {
    BitDebug.instance.isShowing = false
    BitDebug.instance.bitDebugView.removeFromSuperview()
  }
  
  public class func install(rootViewController: UIViewController, forciblyAlwaysDisplay: Bool = false) {
    BitDebug.instance.bitDebugView.rootViewController = rootViewController
    if forciblyAlwaysDisplay {
      let method: Method = class_getInstanceMethod(UIViewController.self,
                                                   #selector(UIViewController.presentViewController(_:animated:completion:)))
      let bd_Method: Method = class_getInstanceMethod(UIViewController.self,
                                                      #selector(UIViewController.bd_presentViewController(_:animated:completion:)))
      method_exchangeImplementations(method, bd_Method)
    }
  }
  
  private init() {
    nc.addObserver(self, selector: #selector(bringFront(_:)), name: UIWindowDidBecomeKeyNotification, object: nil)
  }
  
  deinit {
    nc.removeObserver(self)
  }
  
  @objc private func bringFront(notification: NSNotification) {
    guard notification.object is UIWindow else { return }
    if isShowing {
      BitDebug.show()
    }
  }
}

extension UIViewController {
  func bd_presentViewController(viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?){
    let bd_completion = {
      if BitDebug.instance.isShowing {
        BitDebug.show()
      }
      completion?()
    }
    bd_presentViewController(viewControllerToPresent, animated: animated, completion: bd_completion)
  }
}

private final class BitDebugView: UIView {
  var rootViewController: UIViewController? = nil
  private let baseSize: CGFloat = 50.0
  private let margin: CGFloat   = 44.0
  
  init() {
    let screenBounds = UIScreen.mainScreen().bounds
    let x = screenBounds.width - (margin + baseSize)
    let y = screenBounds.height - (margin + baseSize)
    super.init(frame: CGRect(x: x, y: y, width: baseSize,height: baseSize))
    let pan = UIPanGestureRecognizer(target: self, action: #selector(panAction(_:)))
    let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
    addGestureRecognizer(pan)
    addGestureRecognizer(tap)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    backgroundColor = UIColor.darkGrayColor()
    layer.cornerRadius = 6
    layer.borderColor = UIColor.whiteColor().CGColor
    layer.borderWidth =  2
    let iv = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    iv.image = BitDebugView.bundledImage("bug")
    iv.tintColor = UIColor.whiteColor()
    iv.center = CGPoint(x: bounds.width/2, y: bounds.height/2)
    addSubview(iv)
  }
  
  class func bundledImage(named: String) -> UIImage? {
    let image = UIImage(named: named)
    if image == nil {
      return UIImage(named: named, inBundle: NSBundle(forClass: BitDebug.self), compatibleWithTraitCollection: nil)
    }
    return image
  }
  
  @objc private func panAction(gesture: UIPanGestureRecognizer) {
    var p = gesture.locationInView(superview)
    center = p
    if gesture.state == .Ended {
      guard let superViewFrame = superview?.frame else {return}
      p.x = p.x > superViewFrame.width/2 ? superViewFrame.width - margin : margin
      p.y = p.y < margin ? margin : p.y
      p.y = p.y > superViewFrame.height - margin ? superViewFrame.height - margin : p.y
      UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.7, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
        self.center = p
        }, completion: nil)
    }
  }
  
  @objc private func tapAction(gesture: UITapGestureRecognizer) {
    guard let vc = rootViewController else {
      print("not set rootViewController")
      return
    }
    guard vc.presentingViewController == nil else {
      print("already presented rootViewController")
      return
    }
    let rootVC = findTopViewController(UIApplication.sharedApplication().windows.first?.rootViewController)
    rootVC?.presentViewController(vc, animated: true, completion: nil)
  }
  
  private func findTopViewController(rootVC: UIViewController?) -> UIViewController? {
    if let vc = rootVC as? UITabBarController {
      return findTopViewController(vc.selectedViewController)
    } else if let vc = rootVC as? UINavigationController {
      return findTopViewController(vc.visibleViewController)
    } else if let vc = rootVC?.presentedViewController {
      return findTopViewController(vc)
    } else {
      return rootVC
    }
  }
}