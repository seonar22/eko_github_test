import Foundation

enum APIError: String, Error {
    case noNetwork = "No network to Connect."
    case serverResponseInvalid = "Invliad response from server."
    case permissionDenied = "Unauthorized."
}

protocol APIServiceProtocol {
    func getAllGitHubusers( since userID : Int,complete: @escaping ( _ success: Bool, _ photos: [UserModel], _ error: APIError? )->() )
}


class APIService:APIServiceProtocol {
    
    func getAllGitHubusers( since userID: Int,complete: @escaping ( _ success: Bool, _ photos: [UserModel], _ error: APIError? )->() ) {
        DispatchQueue.global().async {
            sleep(1)
            let url = URL(string: "https://api.github.com/users?since=\(userID)&per_page=5")!
            var request = URLRequest(url: url)
            request.timeoutInterval = 30
            request.setValue(GitHubAPIKey.secret, forHTTPHeaderField: "Authorization")
            
            let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    return
                }
                
                let decoder = JSONDecoder()
                do {let photos = try decoder.decode([UserModel].self, from: data)
                    complete( true, photos, nil )

                    
                }catch{
                    complete( false, [], APIError.serverResponseInvalid )

                }
            }
            dataTask.resume()
            
        }
    }
}
