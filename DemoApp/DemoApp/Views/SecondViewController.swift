//
//  SecondViewController.swift
//  DemoApp
//
//  Created by Pavel Ivashkov on 2016-08-16.
//  Copyright © 2016 paiv. All rights reserved.
//

import UIKit
import SecurityContainer


class SecondViewController: UIViewController {

    @IBAction func handleLogoutButton(sender: AnyObject) {
        securityContainer?.securityLock()
    }
}

