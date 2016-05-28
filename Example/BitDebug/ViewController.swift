//
//  ViewController.swift
//  BitDebug
//
//  Created by Tomoya Hirano on 05/28/2016.
//  Copyright (c) 2016 Tomoya Hirano. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewDidAppear(animated: Bool) {
    let vc = DummyViewController()
    presentViewController(vc, animated: true, completion: nil)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

}

