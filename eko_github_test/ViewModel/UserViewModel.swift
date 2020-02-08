import Foundation

class UserListViewModel {
    
    let apiService: APIServiceProtocol
    
    private var users: [UserModel] = [UserModel]()
    
    private var cellViewModels: [UserListCellViewModel] = [UserListCellViewModel]() {
        didSet {
            usersForStoring=self.cellViewModels
            self.reloadTableViewClosure?()
        }
    }
    
    var usersForStoring:[UserListCellViewModel] = []
    
    var isLoading: Bool = false {
        didSet {
            self.updateLoadingStatus?(isLoading)
        }
    }
    
    var alertMessage: String? {
        didSet {
            self.showAlertClosure?(alertMessage ?? "Unknown Error.")
        }
    }
    
    var numberOfCells: Int {
        return cellViewModels.count
    }
    var selectedGitHubUser: UserListCellViewModel?
    
    var reloadTableViewClosure: (()->())?
    var showAlertClosure: ((_ msg:String)->())?
    var updateLoadingStatus: ((_ isLoading:Bool)->())?
    
    init( apiService: APIServiceProtocol = APIService()) {
        self.apiService = apiService
    }
    
    //MARK: - Network call
    func initFetch(since ID: Int) {
        self.isLoading = true
        apiService.getAllGitHubusers(since: ID) { [weak self] (success, users, error) in
            self?.isLoading = false
            if let error = error {
                self?.alertMessage = error.rawValue
            } else {
                self?.parseResponseForTableCellViewModel(users: users)
            }
        }
    }
    
    func getCellViewModel( at indexPath: IndexPath ) -> UserListCellViewModel {
        return cellViewModels[indexPath.row]
    }
    
    func createCellViewModel( user: UserModel ) -> UserListCellViewModel {
        return UserListCellViewModel( login: user.login, avatarLink: user.avatarURL, githubURL: user.htmlURL, accountType: user.type, siteAdminStatus: user.siteAdmin, favourite: false,id: user.id )
    }
    
    private func parseResponseForTableCellViewModel( users: [UserModel] ) {
        self.users = users // Cache
        var vms = [UserListCellViewModel]()
        for user in users {
            vms.append( createCellViewModel(user: user) )
        }
        self.cellViewModels.append(contentsOf: vms)
    }
}
//MARK: - Return selected user data related to table cell
extension UserListViewModel {
    func userPressed( at indexPath: IndexPath ){
        let user = self.cellViewModels[indexPath.row]
        self.selectedGitHubUser = user
        
    }
}
//MARK: - Tabel Cell View Model
struct UserListCellViewModel {
    //
    //  7. Display each Github user’s :
    //  7.1. Login as text
    //  7.2. Avatar as an image
    //  7.3. Github url as text
    //  7.4. Account type as text
    //  7.5. Site admin status as text
    //  7.6. The users favorite status for the Github user.
    
    // MARK: - Properties
    public let login: String
    public let avatarLink: String
    public let githubURL: String
    
    public let accountType: String
    public let siteAdminStatus: Bool
    
    public var favourite: Bool
    public let id: Int
}
