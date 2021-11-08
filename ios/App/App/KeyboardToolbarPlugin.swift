import Foundation
import Capacitor
import UIKit

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(KeyboardToolbarPlugin)
public class KeyboardToolbarPlugin: CAPPlugin {
    private let implementation = KeyboardToolbar()
    
    private var toolbar: UIToolbar?
    private var call: CAPPluginCall?
    private var isEnabled = false
    
    override public func load() {
        let notifier = NotificationCenter.default
        notifier.addObserver(self,
                             selector: #selector(keyboardWillHideNotification(_:)),
                             name: UIWindow.keyboardWillHideNotification,
                             object: nil)
        
        let numberToolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        numberToolbar.barStyle = .black
        numberToolbar.isTranslucent = true
        numberToolbar.items = [
            UIBarButtonItem(title: "✅", style: .plain, target: self, action: #selector(self.handleCheckbox)),
            UIBarButtonItem(title: "🔘", style: .plain, target: self, action: #selector(self.handleBullet)),
            UIBarButtonItem(title: "❌", style: .plain, target: self, action: #selector(self.handleClose))]
        numberToolbar.sizeToFit()
        webView?.addInputAccessoryView(toolbar: numberToolbar)
    }
    
    @objc
    func keyboardWillHideNotification(_ notification: NSNotification) {
        isEnabled = false
    }
    

    @objc func setup(_ call: CAPPluginCall) {
        self.call = call
        self.call?.keepAlive = true
        self.call?.resolve()
    }
    
    @objc func enable(_ call: CAPPluginCall) {
        self.isEnabled = true
        call.resolve()
    }
    
    @objc func disable(_ call: CAPPluginCall) {
        self.isEnabled = false
        call.resolve()
    }
    
    @objc func handleCheckbox() {
        //Cancel with number pad
        self.call?.resolve([
            "button": "checkbox"
        ])
    }
    @objc func handleBullet() {
        //Done with number pad
        self.call?.resolve([
            "button": "bullet"
        ])
    }
    @objc func handleClose() {
        //Done with number pad
        self.call?.resolve([
            "button": ""
        ])
        webView?.resignFirstResponder()
    }
    

}

var ToolbarHandle: UInt8 = 0

extension WKWebView {

    func addInputAccessoryView(toolbar: UIView?) {
        guard let toolbar = toolbar else {return}
        objc_setAssociatedObject(self, &ToolbarHandle, toolbar, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        var candidateView: UIView? = nil
        for view in self.scrollView.subviews {
            let description : String = String(describing: type(of: view))
            if description.hasPrefix("WKContent") {
                candidateView = view
                break
            }
        }
        guard let targetView = candidateView else {return}
        let newClass: AnyClass? = classWithCustomAccessoryView(targetView: targetView)

        guard let targetNewClass = newClass else {return}

        object_setClass(targetView, targetNewClass)
    }

    func classWithCustomAccessoryView(targetView: UIView) -> AnyClass? {
        guard let _ = targetView.superclass else {return nil}
        let customInputAccesoryViewClassName = "_CustomInputAccessoryView"

        var newClass: AnyClass? = NSClassFromString(customInputAccesoryViewClassName)
        if newClass == nil {
            newClass = objc_allocateClassPair(object_getClass(targetView), customInputAccesoryViewClassName, 0)
        } else {
            return newClass
        }

        let newMethod = class_getInstanceMethod(WKWebView.self, #selector(WKWebView.getCustomInputAccessoryView))
        class_addMethod(newClass.self, #selector(getter: WKWebView.inputAccessoryView), method_getImplementation(newMethod!), method_getTypeEncoding(newMethod!))

        objc_registerClassPair(newClass!)

        return newClass
    }

    @objc func getCustomInputAccessoryView() -> UIView? {
        var superWebView: UIView? = self
        while (superWebView != nil) && !(superWebView is WKWebView) {
            superWebView = superWebView?.superview
        }

        guard let webView = superWebView else {return nil}

        let customInputAccessory = objc_getAssociatedObject(webView, &ToolbarHandle)
        return customInputAccessory as? UIView
    }
}
