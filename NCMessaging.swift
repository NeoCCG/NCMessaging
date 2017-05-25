//
//  NCMessaging.swift
//
//  Created by Neo Chen on 26/04/2017.
//  Copyright © 2017 NCG. All rights reserved.
//

import UIKit

class NCMessaging {
    
    enum NCMessagingType {
        case alert
        case actionSheet
        case toast
    }
    
    typealias NCMessagingCallback = (Int) -> Void
    
    class func alert(title:String = "", message:String?, callback:NCMessagingCallback?, buttons:String...) {
        let alert = _NCMessagingBOX()
        alert.type = .alert
        alert.title = title
        alert.message = message
        alert.callback = callback
        alert.btns = buttons
        alert.show()
    }
    
    class func actionSheet(title:String? = nil, callback:NCMessagingCallback?, cancel:String?, buttons:String...) {
        let actionSheet = _NCMessagingBOX()
        actionSheet.type = .actionSheet
        actionSheet.title = title
        actionSheet.callback = callback
        actionSheet.btnCancel = cancel
        actionSheet.btns = buttons
        actionSheet.show()
    }
    
    class func toast(message:String, callback:NCMessagingCallback?) {
        let toast = _NCMessagingBOX()
        toast.type = .toast
        toast.message = message
        toast.callback = callback
        toast.show()
    }
    
    private init() {
        
    }

}

private class _NCMessagingBOX:NSObject {
    
    fileprivate var vKeeper:_NCMessagingBOX?
    fileprivate var type:NCMessaging.NCMessagingType = .toast
    fileprivate var title:String?
    fileprivate var message:String?
    fileprivate var btnCancel:String?
    fileprivate var btns:[String]?
    fileprivate var callback:NCMessaging.NCMessagingCallback?
    
    deinit {
        callback = nil
    }
    
    fileprivate override init() {
        super.init()
    }
}

extension _NCMessagingBOX {
    
    fileprivate func topVC() -> UIViewController? {
        if var vc = UIApplication.shared.keyWindow?.rootViewController {
            while let pvc = vc.presentedViewController {
                vc = pvc
            }
            return vc
        }
        return nil
    }
    
    fileprivate func show() {
        
        func showVC(type:UIAlertControllerStyle) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: type)
            var preIndex = 0
            if let btn = btnCancel {
                preIndex = 1
                alert.addAction(UIAlertAction(title: btn, style: .cancel, handler: { (action) in
                    self.callback?(0)
                }))
            }
            for i in 0..<(btns ?? []).count {
                alert.addAction(UIAlertAction(title: btns![i], style: .default, handler: { (action) in
                    self.callback?(preIndex + i)
                }))
            }
            if let vc = topVC() {
                DispatchQueue.main.async {
                    vc.present(alert, animated: true, completion: nil)
                }
            }
        }
        
        switch type {
        case .alert:
            if #available(iOS 8, *) {
                showVC(type: .alert)
            }else{
                let alert = UIAlertView(title: title, message: message, delegate: self, cancelButtonTitle: nil)
                for i in 0..<(btns ?? []).count {
                    alert.addButton(withTitle: btns![i])
                }
                DispatchQueue.main.async {
                    alert.show()
                }
                vKeeper = self
            }
        case .actionSheet:
            if #available(iOS 8, *) {
                showVC(type: .actionSheet)
            }else{
                let actionSheet = UIActionSheet(title: title, delegate: self, cancelButtonTitle: btnCancel, destructiveButtonTitle: nil)
                for i in 0..<(btns ?? []).count {
                    actionSheet.addButton(withTitle: btns?[i])
                }
                if let v = UIApplication.shared.keyWindow {
                    actionSheet.show(in: v)
                    vKeeper = self
                }
            }
        case .toast:
            if let v = topVC()?.view {
                self.vKeeper = self
                let l = UITextView()
                v.addSubview(l)
                l.isUserInteractionEnabled = false
                l.bounds = CGRect(x: 0, y: 0, width: v.frame.width - 30, height: 0)
                l.backgroundColor = UIColor(white: 0, alpha: 0.35)
                l.textColor = UIColor.white
                l.text = message
                l.textContainerInset = UIEdgeInsetsMake(8, 8, 8, 8)
                l.layer.borderColor = UIColor(white: 0.9, alpha: 1).cgColor
                l.layer.borderWidth = 1
                l.layer.cornerRadius = 5
                l.layer.masksToBounds = true
                l.sizeToFit()
                l.center = v.center
                l.center.y = v.frame.maxY - l.frame.height / 2 - 40
                l.alpha = 0
                UIView.animate(withDuration: 0.3, animations: { 
                    l.alpha = 1
                }, completion: { (completed) in
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: {
                        UIView.animate(withDuration: 0.3, animations: { 
                            l.alpha = 0
                        }, completion: { (done) in
                            l.removeFromSuperview()
                            self.callback?(0)
                            self.vKeeper = nil
                        })
                    })
                })
            }
        }
    }
    
}

extension _NCMessagingBOX: UIAlertViewDelegate {
    
    @available(*, deprecated: 9.0, message: "Use UIAlertController")
    func alertView(_ alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        callback?(buttonIndex)
        vKeeper = nil
    }
    
}

extension _NCMessagingBOX: UIActionSheetDelegate {
    
    @available(*, deprecated: 8.3, message: "Use UIAlertController")
    func actionSheet(_ actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
        callback?(buttonIndex)
        vKeeper = nil
    }
    
}
