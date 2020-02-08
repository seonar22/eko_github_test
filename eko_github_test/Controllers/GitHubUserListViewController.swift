import Foundation
import UIKit
import CoreData

class GitHubUserListViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyDataContainer: UIView!
    
    //MARK: - Properties
    private let spinnerVC = SpinnerViewController()
    private var latestID = 1
    
    
    private var favIDs:[Int] = []
    
    private var favUserID: [NSManagedObject] = []
    
    
    lazy private var viewModel: UserListViewModel = {
        return UserListViewModel()
    }()
    
    private var vcViewModelList: [UserListCellViewModel] = []
    
    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        debugPrint("API KEY:....\(GitHubAPIKey.secret)")
        initView()
        
        initVM()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        tableView.reloadData()
        
        favUserID = DataStoreManager.getAllFavouriteIDs()
        for favIdObj in favUserID{
            let value = favIdObj.value(forKeyPath: "id") as? Int
            guard let valueUnwrapped = value else{return}
            favIDs.append(valueUnwrapped)
        }
        
    }
    
    
    //MARK: - Private Methods
    private func initView() {
        tableView.delegate = self
        tableView.dataSource = self
        // tableview setup with XIB/NIB tableCell
        let userCellNibName = UINib(nibName: "UserListTableViewCell", bundle: nil)
        tableView.register(userCellNibName, forCellReuseIdentifier: "UserListTableViewCell")
    }
    private func initVM() {
        
        viewModel.reloadTableViewClosure = { [weak self] () in
            guard let self = self else{return}
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.removeSpinner()
                if (self.viewModel.numberOfCells < 1){
                    self.view.bringSubviewToFront(self.emptyDataContainer)
                }else{
                    self.view.bringSubviewToFront(self.tableView)
                }
            }
        }
        viewModel.showAlertClosure = { [weak self] message in
            guard let self = self else {return}
            DispatchQueue.main.async {
                AlertHelper.popupMessageWithCallback(title: "", msg: "\(message)\nPlease Try Again!", vc: self, btnLabel: "OK"){
                    self.viewModel.initFetch(since: self.latestID)
                    self.addSpinnner()
                }
            }
            
        }
        //        viewModel.updateLoadingStatus = { [weak self] isLoading in
        //            DispatchQueue.main.async {
        //
        //            }
        //
        //        }
        
        viewModel.initFetch(since: latestID)
        addSpinnner()
        
    }
    
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension GitHubUserListViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return viewModel.numberOfCells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserListTableViewCell") as! UserListTableViewCell
        
        var cellVM = viewModel.getCellViewModel( at: indexPath )
        
        let isFav = favIDs.contains(cellVM.id) ? true : false
        cellVM.favourite = isFav
        cell.userListCellViewModel = cellVM
        
        if indexPath.row == viewModel.numberOfCells - 1 {
            latestID = cellVM.id
            viewModel.initFetch(since: cellVM.id)
            addSpinnner()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toDetail", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        self.viewModel.userPressed(at: indexPath)
        return indexPath
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserListTableViewCell") as! UserListTableViewCell
        cell.isSelected = false
    }
    
    
}

extension GitHubUserListViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail"{
            
            if let vc = segue.destination as? UserDetailViewController{
                vc.id = viewModel.selectedGitHubUser!.id
                vc.isFav = favIDs.contains(viewModel.selectedGitHubUser?.id ?? -1)
                vc.urlString = viewModel.selectedGitHubUser?.githubURL
                vc.modalPresentationStyle = .fullScreen
            }
        }
    }
}
//MARK: - Spinner
extension GitHubUserListViewController{
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
