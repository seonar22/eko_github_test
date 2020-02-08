import UIKit
extension UIImageView {
    func downloadImageFrom(link:String, contentMode: UIView.ContentMode) {
        URLSession.shared.dataTask( with: URL(string:link)!, completionHandler: {
            (data, response, error) -> Void in
            DispatchQueue.main.async {
                self.contentMode =  contentMode
                if let data = data { self.image = UIImage(data: data)
                    
                }else {
                    self.image = UIImage.init(systemName: "person.fill")
                }
            }
        }).resume()
    }
}
class UserListTableViewCell: UITableViewCell {
    @IBOutlet weak var loginName: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var gitHubURL: UILabel!
    @IBOutlet weak var accType: UILabel!
    @IBOutlet weak var adminStatus: UILabel!
    @IBOutlet weak var favIcon: UIImageView!
    var userListCellViewModel : UserListCellViewModel? {
        didSet {
            loginName.text = userListCellViewModel?.login
            gitHubURL.text = userListCellViewModel?.githubURL
            accType.text = userListCellViewModel?.accountType
            adminStatus.text = (userListCellViewModel?.siteAdminStatus ?? false) ? "Admin" : "Not Admin"
            avatar.downloadImageFrom(link: userListCellViewModel!.avatarLink, contentMode: .scaleAspectFill)
            let _ = (userListCellViewModel?.favourite ?? false) ? (favIcon.image = UIImage.init(systemName: "heart.fill")) : (favIcon.image = UIImage.init(systemName: "heart"))
        }
    }
    
}
