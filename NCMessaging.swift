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
        case banners
    }
    
    typealias NCMessagingCallback = (Int) -> Void
    
    class func alert(title:String = "", message:String?, callback:NCMessagingCallback? = nil, buttons:String...) {
        let alert = _NCMessagingBOX()
        alert.type = .alert
        alert.title = title
        alert.message = message
        alert.callback = callback
        alert.btns = buttons
        alert.show()
    }
    
    class func actionSheet(title:String? = nil, callback:NCMessagingCallback? = nil, cancel:String?, buttons:String...) {
        let actionSheet = _NCMessagingBOX()
        actionSheet.type = .actionSheet
        actionSheet.title = title
        actionSheet.callback = callback
        actionSheet.btnCancel = cancel
        actionSheet.btns = buttons
        actionSheet.show()
    }
    
    class func toast(message:String, callback:NCMessagingCallback? = nil) {
        let toast = _NCMessagingBOX()
        toast.type = .toast
        toast.message = message
        toast.callback = callback
        toast.show()
    }
    
    class func banners(title:String? = nil, message:String?, callback:NCMessagingCallback? = nil) {
        let banners = _NCMessagingBOX()
        banners.type = .banners
        banners.title = title
        banners.message = message
        banners.callback = callback
        banners.show()
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
    
    fileprivate lazy var toastView:UITextView = {
        let f = UIScreen.main.bounds
        let l = UITextView()
        l.isUserInteractionEnabled = false
        l.bounds = CGRect(x: 0, y: 0, width: f.width - 30, height: 0)
        l.backgroundColor = UIColor(white: 0, alpha: 0.35)
        l.textColor = UIColor.white
        l.text = self.message
        l.textContainerInset = UIEdgeInsetsMake(8, 8, 8, 8)
        l.layer.borderColor = UIColor(white: 0.9, alpha: 1).cgColor
        l.layer.borderWidth = 1
        l.layer.cornerRadius = 5
        l.layer.masksToBounds = true
        l.sizeToFit()
        l.center = CGPoint(x:f.width/2 , y:f.maxY - l.frame.height / 2 - 40)
        l.alpha = 0
        return l
    }()
    
    fileprivate lazy var bannersView:UIView = {
        let f = UIScreen.main.bounds
        let v:UIView
        if #available(iOS 8, *) {
            v = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        }else{
            v = UIView()
            v.backgroundColor = UIColor(white: 0, alpha: 0.75)
        }
        v.frame = CGRect(x: 0, y: -100, width: f.width, height: 100)
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.gestureAction(sender:)))
        swipe.direction = .up
        v.addGestureRecognizer(swipe)
        v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.gestureAction(sender:))))
        
        let lblTitle = UILabel()
        lblTitle.textColor = UIColor.white
        lblTitle.font = UIFont.boldSystemFont(ofSize: 17)
        lblTitle.frame = CGRect(x: 20, y: 20, width: f.width - 40, height: 30)
        lblTitle.text = self.title
        
        let lblSubtitle = UILabel()
        lblSubtitle.textColor = UIColor.white
        lblSubtitle.font = UIFont.systemFont(ofSize: 14)
        lblSubtitle.numberOfLines = 2
        lblSubtitle.frame = CGRect(x: 20, y: 50, width: f.width - 40, height: v.frame.height - 50 - 10)
        lblSubtitle.text = self.message
        lblSubtitle.sizeToFit()
        v.addSubview(lblTitle)
        v.addSubview(lblSubtitle)
        return v
    }()
    
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
            while let pvc = vc.presentedViewController, !pvc.isKind(of: UIAlertController.self) {
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
                v.addSubview(toastView)
                UIView.animate(withDuration: 0.3, animations: { 
                    self.toastView.alpha = 1
                }, completion: { (completed) in
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: {
                        UIView.animate(withDuration: 0.3, animations: { 
                            self.toastView.alpha = 0
                        }, completion: { (done) in
                            self.toastView.removeFromSuperview()
                            self.callback?(0)
                            self.vKeeper = nil
                        })
                    })
                })
            }
        case .banners:
            if let v = topVC()?.view {
                self.vKeeper = self
                v.addSubview(bannersView)
                UIView.animate(withDuration: 0.3, animations: { 
                    self.bannersView.frame.origin.y = 0
                }, completion: { (completed) in
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: {
                        if self.vKeeper != nil {
                            self.removeBannersView(clicked: false)
                        }
                    })
                })
            }
        }
    }
    
    func gestureAction(sender:UIGestureRecognizer) {
        if sender is UISwipeGestureRecognizer {
            removeBannersView(clicked: false)
        }else if sender is UITapGestureRecognizer {
            removeBannersView(clicked: true)
        }
        
    }
    
    fileprivate func removeBannersView(clicked:Bool) {
        UIView.animate(withDuration: 0.3, animations: {
            self.bannersView.frame.origin.y = -self.bannersView.frame.height
        }, completion: { (done) in
            self.bannersView.removeFromSuperview()
            self.callback?(clicked ? 1 : 0)
            self.vKeeper = nil
        })
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
