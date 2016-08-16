//
//  LoginViewController.swift
//  DemoApp
//
//  Created by Pavel Ivashkov on 2016-08-17.
//  Copyright © 2016 paiv. All rights reserved.
//

import UIKit
import SecurityContainer


class LoginViewController: UIViewController {

    @IBAction func handleLoginButton(sender: AnyObject) {
        securityContainer?.securityUnlock()
    }
    
}
