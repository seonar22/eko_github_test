import UIKit
import WebKit
class UserDetailViewController: UIViewController {
    //MARK: - Properties
    //Data sent from parent VC
    var urlString: String?
    var isFav:Bool = false
    var id:Int = -1
    //UI
    private let spinnerVC = SpinnerViewController()
    
    //MARK: - Outlets
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var favBtn: UIButton!
    
    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.load(URLRequest(url: URL(string: urlString ?? "")!))
        
        let _ = isFav ? (favBtn.setBackgroundImage(UIImage.init(systemName: "heart.fill") ,for: [.normal,])) : (favBtn.setBackgroundImage(UIImage.init(systemName: "heart") ,for: [.normal]))
        
        addSpinnner()
    }
    override func viewWillDisappear(_ animated: Bool) {
        webView.stopLoading()
    }
    
    //MARK: - IBActions
    @IBAction func backToParent(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func toggleFav(_ sender: Any) {
        guard id > 0 else {return}
        var dataChnageSuccess = false
        addSpinnner()
        if isFav{
            
            dataChnageSuccess = DataStoreManager.deleteFavID(id: id)
            
        }else{
            dataChnageSuccess = DataStoreManager.saveFavID(id: id)
        }
        removeSpinner()
        guard dataChnageSuccess else {
            AlertHelper.popupMessage(title: "", msg: "Cannot change favourite status!\nPlease Try Again", vc: self, btnLabel: "OK")
            return
        }
        isFav = !isFav
        let _ = isFav ? (favBtn.setBackgroundImage(UIImage.init(systemName: "heart.fill") ,for: .normal)) : (favBtn.setBackgroundImage(UIImage.init(systemName: "heart") ,for: .normal))
    }
}
//MARK: - WKUIDelegate,WKNavigationDelegate
extension UserDetailViewController: WKUIDelegate,WKNavigationDelegate{
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        removeSpinner()
        AlertHelper.popupMessage(title: "Opps!", msg: "Cannot connect to server.\nPlease try again later.", vc: self, btnLabel: "OK")
        
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        removeSpinner()
        AlertHelper.popupMessage(title: "Opps!", msg: "Cannot connect to server.\nPlease try again later.", vc: self, btnLabel: "OK")
        
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse,
                 decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        removeSpinner()
        if let response = navigationResponse.response as? HTTPURLResponse {
            switch  response.statusCode{
            case 200 ... 299:
                break
            case 400 ... 499:
                AlertHelper.popupMessage(title: "Unauthorized", msg: "Check at API Key in App", vc: self, btnLabel: "OK")
            default:
                AlertHelper.popupMessage(title: "Opps!", msg: "Cannot connect to server.\nPlease try again later.", vc: self, btnLabel: "OK")
            }
        }
        decisionHandler(.allow)
    }
}
//MARK: - Spinner
extension UserDetailViewController{
    //MARK: - Private Methods
    private func addSpinnner(){
        addChild(spinnerVC)
        spinnerVC.view.frame = view.frame
        view.addSubview(spinnerVC.view)
        spinnerVC.didMove(toParent: self)
        
    }
    private func removeSpinner(){
        spinnerVC.willMove(toParent: nil)
        spinnerVC.view.removeFromSuperview()
        spinnerVC.removeFromParent()
    }
}
