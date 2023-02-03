//
//  AuthManager.swift
//  Spotify
//
//  Created by Владислав Калинин on 13.12.2022.
//

import Foundation

final class AuthManager {
// MARK: - PROPERTIES
    
    // MARK: External properties:
    
    struct Constants {
        static let clientID = "27d4aa5c3c1e4eb68f12d33b03b3e27c"
        static let clientSecret = "55e11c4930c5409aa0d76460f291dd0b"
        static let tokenAPIURL = "https://accounts.spotify.com/api/token"
        static let redirectURI = "https://www.iosacademy.io"
        static let scopes = "user-read-private%20playlist-modify-public%20playlist-read-private%20playlist-modify-private%20user-follow-read%20user-library-modify%20user-library-read%20user-read-email" 
    }
    
    static let shared = AuthManager()
    
    public var signInURL: URL? {
        let base = "https://accounts.spotify.com/authorize"
        let string = "\(base)?response_type=code&client_id=\(Constants.clientID)&scope=\(Constants.scopes)&redirect_uri=\(Constants.redirectURI)&show_dialog=TRUE"
        print(string)
        return URL(string: string)
        
    }
    
    var isSignedIn: Bool {
        return accessToken != nil
    }
    
    // MARK: Internal properties:
    
    private var refreshingToken = false
    
    private var accessToken: String? {
        return UserDefaults.standard.string(forKey: "access_token")
    }
    
    private var refreshToken: String? {
        return UserDefaults.standard.string(forKey: "refresh_token")
    }
    
    private var tokenExpirationDate: Date? {
        return UserDefaults.standard.object(forKey: "expirationDate") as? Date
    }
    
    private var shouldRefreshToken: Bool {
        guard let expirationDate = tokenExpirationDate else { return false }
        
        let currentDate = Date()
        let fiveMinutes: TimeInterval = 300
        return currentDate.addingTimeInterval(fiveMinutes) >= expirationDate
    }
    
    private var onRefreshBlocks = [((String) -> Void)]()
    
// MARK: - LIFECYCLE
    
    private init() {
        
    }
    
// MARK: - FUNCTIONS
    
    // MARK: External functions:
    
    public func exchangeCodeForToken(code: String, completion: @escaping (Bool) -> Void) {
        
        // UNWRAP URL
        guard let url = URL(string: Constants.tokenAPIURL) else { return }
        
        // COMPOSE REQ. BODY PARAMS
        var components = URLComponents()
        components.queryItems = [
            
            URLQueryItem(name: "grant_type",
                         value: "authorization_code"),
            
            URLQueryItem(name: "code",
                         value: code),
            
            URLQueryItem(name: "redirect_uri",
                         value: Constants.redirectURI)
        ]
        
        // COMPOSE REQUEST
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = components.query?.data(using: .utf8)
        
        let basicToken = Constants.clientID+":"+Constants.clientSecret
        let data = basicToken.data(using: .utf8)
        
        guard let base64String = data?.base64EncodedString() else {
            print("Failed to get 64")
            completion(false)
            return
        }
        
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        
        // MAKE REQUEST ACCESS TOKEN
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            
            guard let data = data, error == nil else {
                completion(false)
                return
            }
            
            do {
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                self?.cacheToken(result: result)
                completion(true)
            } catch {
                print(error.localizedDescription)
                completion(false)
            }
        }
        
        task.resume()
    }
    
    public func withValidToken(completion: @escaping (String) -> Void) {
        
        guard !refreshingToken else {
            onRefreshBlocks.append(completion)
            return
        }
        
        if shouldRefreshToken {
            refreshIfNeeded { [weak self] success in 
                    if let token = self?.accessToken, success {
                        completion(token)
                }
            }
        }
        else if let token = accessToken {
            completion(token)
        }
        
    }
    
    // REFRESH TOKEN
    public func refreshIfNeeded(completion: ((Bool) -> Void)?) {
        
        guard !refreshingToken else { return }
        
        guard shouldRefreshToken else {
            completion?(true)
            return
        }
        
        // UNWRAP REFRESH_TOKEN
        guard let refreshToken = self.refreshToken else { return }
        
        // UNWRAP THE TOKEN_URL
        guard let url = URL(string: Constants.tokenAPIURL) else { return }
        
        refreshingToken = true
        
        var components = URLComponents()
        
        // COMPOSE QUERY BODY
        components.queryItems = [
            
            URLQueryItem(name: "grant_type", value: "refresh_token"),
            
            URLQueryItem(name: "refresh_token", value: refreshToken)
        ]
        
        // CONFIG REQUEST STRUCTURE
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = components.query?.data(using: .utf8)
        
        let basicToken = Constants.clientID+":"+Constants.clientSecret
        let data = basicToken.data(using: .utf8)
        
        guard let base64String = data?.base64EncodedString() else {
            print("Failed to get 64")
            completion?(false)
            return
        }
        
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        
        // MAKE REQUEST
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            
            self?.refreshingToken = false
            
            guard let data = data, error == nil else {
                completion? (false)
                return
            }
            
            do {
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                
                self?.onRefreshBlocks.forEach { $0(result.access_token) }
                self?.onRefreshBlocks.removeAll()
                self?.cacheToken(result: result)
                completion?(true)
            } catch {
                print(error.localizedDescription)
                completion?(false)
            }
            
        }
        
        task.resume()
    }
    
    // MARK: Internal functions:
    
    //CACHE FETCHED DATA BY MODEL
    private func cacheToken(result: AuthResponse) {
        UserDefaults.standard.setValue(result.access_token, forKey: "access_token")
        if let refresh_token = result.refresh_token {
            UserDefaults.standard.setValue(refresh_token, forKey: "refresh_token")
        }
        UserDefaults.standard.setValue(Date().addingTimeInterval(TimeInterval(result.expires_in)), forKey: "expirationDate")
    }
    
}
