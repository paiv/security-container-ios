//
//  SecurityContainer.swift
//  SecurityContainer
//
//  Created by Pavel Ivashkov on 2016-08-17.
//

import UIKit


public protocol SecurityContainerDelegate : class {
    
    func securityContainerDidLogin(securityContainer: SecurityContainer)
    func securityContainerDidLogout(securityContainer: SecurityContainer)
}


/**
 SecurityContainer relies on two segues:
 * locked - to present Login flow
 * unlocked - to navigate to the rest of the app
 In a storyboard, use custom SecuritySegue with one of the two identifiers above.
 
 Animation: mimics push-pop animation of UINavigationController
 */
public class SecurityContainer : UIViewController {
    
    static let DefaultAnimationDuration = 0.3
    
    public func securityLock() {
        performSegueWithIdentifier(SecuritySegueIdentifier.Locked.rawValue, sender: self)
    }
    
    public func securityUnlock() {
        performSegueWithIdentifier(SecuritySegueIdentifier.Unlocked.rawValue, sender: self)
    }
    
    var animationDuration = SecurityContainer.DefaultAnimationDuration
    
    var delegate: SecurityContainerDelegate?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        securityLock()
    }
    
    private enum Animation {
        case None
        case Push
        case Pop
    }
    
    internal func displayLocked(viewController: UIViewController, animated: Bool) {
        displayChildViewController(viewController, animation: (animated ? .Pop : .None))
        delegate?.securityContainerDidLogout(self)
    }
    
    internal func displayUnlocked(viewController: UIViewController, animated: Bool) {
        displayChildViewController(viewController, animation: (animated ? .Push : .None))
        delegate?.securityContainerDidLogin(self)
    }
    
    private func displayChildViewController(child: UIViewController, animation: Animation) {
        
        let current = childViewControllers.first
        current?.willMoveToParentViewController(nil)
        
        child.securityContainer = self
        addChildViewController(child)
        
        if current == nil || animation == .None || animationDuration <= 0 {
            child.view.frame = view.bounds
            view.addSubview(child.view)
            child.didMoveToParentViewController(self)
            
            current?.view.removeFromSuperview()
            current?.removeFromParentViewController()
            current?.securityContainer = nil
        }
        else {
            let containerBounds = self.view.bounds
            let offscreenRight = CGRectOffset(containerBounds, containerBounds.width, 0)
            let nudgeLeft = CGRectOffset(containerBounds, -0.25 * containerBounds.width, 0)
            
            let newChildOriginFrame = animation == .Push ? offscreenRight : nudgeLeft
            let newChildTargetFrame = containerBounds
            let oldChildTargetFrame = animation == .Push ? nudgeLeft : offscreenRight
            
            child.view.frame = newChildOriginFrame
            
            if animation == .Push {
                view.addSubview(child.view)
            }
            else {
                view.insertSubview(child.view, atIndex: 0)
            }
            
            let adjustedDuration = animation == .Push ? animationDuration : (0.9 * animationDuration)
            
            if let layer = (animation == .Push ? child.view.layer : current?.view.layer) {
                layer.shadowColor = UIColor.blackColor().CGColor
                layer.shadowOffset = CGSize(width: -4, height: 0)
                layer.shadowRadius = 4
                layer.shadowOpacity = 0
                
                let anim = CABasicAnimation(keyPath: "shadowOpacity")
                anim.fromValue = NSNumber(double: 0.2)
                anim.toValue = NSNumber(double: 0)
                anim.duration = adjustedDuration
                layer.addAnimation(anim, forKey: "shadowOpacity")
            }
            
            UIView.transitionWithView(view, duration: adjustedDuration, options: [.CurveEaseOut], animations: {
                
                child.view.frame = newChildTargetFrame
                current?.view.frame = oldChildTargetFrame
                
                }, completion: { _ in
                    
                    child.didMoveToParentViewController(self)
                    current?.view.removeFromSuperview()
                    current?.removeFromParentViewController()
                    current?.securityContainer = nil
            })
        }
    }
}


var SecurityContainerAssociatedObjectKey: UInt8 = 0

extension UIViewController {
    public var securityContainer: SecurityContainer? {
        get {
            var vc: UIViewController? = self
            repeat {
                if let res = objc_getAssociatedObject(vc, &SecurityContainerAssociatedObjectKey) as? SecurityContainer {
                    return res
                }
                vc = vc?.parentViewController
            }
                while(vc != nil)
            return nil
        }
        set {
            objc_setAssociatedObject(self, &SecurityContainerAssociatedObjectKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}