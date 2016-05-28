//
//  DummyViewController.swift
//  BitDebug
//
//  Created by Tomoya Hirano on 2016/05/28.
//  Copyright © 2016年 CocoaPods. All rights reserved.
//

import UIKit

final class DummyViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = getRandomColor()
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    if touches.first?.locationInView(view).x < view.bounds.width / 2 {
      dismissViewControllerAnimated(true, completion: nil)
    } else {
      presentViewController(DummyViewController(), animated: true, completion: nil)
    }
  }

  private func getRandomColor() -> UIColor{
    let randomRed:CGFloat = CGFloat(drand48())
    let randomGreen:CGFloat = CGFloat(drand48())
    let randomBlue:CGFloat = CGFloat(drand48())
    return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    
  }
}
