import UIKit

final class AlertHelper{
    static func popupMessage(title: String, msg : String, vc: UIViewController, btnLabel: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { // change 2 to desired number of seconds
            
            if msg != "" {
                let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: btnLabel, style: .default, handler: { action in
                    switch action.style{
                    case .default:
                        break
                    case .cancel:
                        break
                    case .destructive:
                        break
                    @unknown default:
                        break
                    }}))
                vc.present(alert, animated: true, completion: nil)
            } // end if
        }
    }
    static func popupMessageWithCallback(title: String, msg : String, vc: UIViewController, btnLabel: String, callback: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { // change 2 to desired number of seconds
            
            if msg != "" {
                let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: btnLabel, style: .default, handler: { action in
                    
                    switch action.style{
                    case .default:
                        callback()
                        
                    case .cancel:
                        break
                    case .destructive:
                        break
                    @unknown default:
                        break
                    }}))
                vc.present(alert, animated: true, completion: nil)
            } // end if
        }
    }
}
