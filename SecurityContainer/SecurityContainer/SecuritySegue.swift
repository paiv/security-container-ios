//
//  SecuritySegue.swift
//  SecurityContainer
//
//  Created by Pavel Ivashkov on 2016-08-17.
//

import UIKit


public enum SecuritySegueIdentifier : String {
    case Unlocked = "unlocked"
    case Locked = "locked"
}

public class SecuritySegue: UIStoryboardSegue {
    
    public override func perform() {
        
        if let securityContainer = self.sourceViewController as? SecurityContainer {
            
            if identifier == SecuritySegueIdentifier.Locked.rawValue {
                securityContainer.displayLocked(destinationViewController, animated: UIView.areAnimationsEnabled())
            }
            else if identifier == SecuritySegueIdentifier.Unlocked.rawValue {
                securityContainer.displayUnlocked(destinationViewController, animated: UIView.areAnimationsEnabled())
            }
            
        }
    }
}
