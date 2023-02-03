//
//  APICaller.swift
//  Spotify
//
//  Created by Владислав Калинин on 13.12.2022.
//

import Foundation

final class APICaller {
    
    static let shared = APICaller()
    
    enum HTTPMethod: String {
        case GET
        case POST
    }
    
    struct Constants {
        static let baseAPIURL = "https://api.spotify.com/v1/me"
        static let baseAPIReq = "https://api.spotify.com/v1"
    }
    
    enum APIError: Error {
        case failedToGetData
    }
    
    private init() {
        
    }
    
    public func getCurrentUserProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        createRequest(
            with: URL(string: Constants.baseAPIURL),
            type: .GET) { baseRequest in
                
                let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                    guard let data = data, error == nil else {
                        completion(.failure(APIError.failedToGetData))
                        return
                        
                    }
                    
                    do {
                        let result = try JSONDecoder().decode(UserProfile.self, from: data)
                        print(result)
                        completion(.success(result))
                    } catch {
                        completion(.failure(APIError.failedToGetData))
                        print("DEBUG: Error \(error)")
                    }
                }
                
                task.resume()
        }
    }
    
    public func getNewReleases(completion: @escaping (Result<NewReleasesResponse, Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIReq + "/browse/new-releases?limit=50"), type: .GET) { request in
            
            let promise = URLSession.shared.dataTask(with: request) { data, _, error in
                
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(NewReleasesResponse.self, from: data)
                    completion(.success(result))
                    print(result)
                } catch {
                    print("DEBUG: Error \(error)")
                    completion(.failure(error))
                }
                
            }
            promise.resume()
        }
    }
    
    public func getFeaturedPlaylists (completion: @escaping (Result<FeaturedPlaylistResponse , Error>) -> Void) {
        createRequest(
            with: URL(string: Constants.baseAPIReq + "/browse/featured-playlists?limit=1"),
            type: .GET) { request in
            
            let promise = URLSession.shared.dataTask(with: request) { data, _, error in
                
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(FeaturedPlaylistResponse.self, from: data)
                    completion(.success(result))
                    print(result)
                    print("SUCCESS")
                } catch {
                    print("ERROR DESCRIPTION: \(error)")
                    completion(.failure(error))
                }
                
            }
            promise.resume()
        }
    }
    
    public func getRecommendations (genres: Set<String> , completion: @escaping (Result<String , Error>) -> Void) {
        
        let seeds = genres.joined(separator: ",")
        
        createRequest(with: URL(string: Constants.baseAPIReq + "/recommendations?seed_genres=\(seeds)"), type: .GET) { request in
            print(request.url?.absoluteURL)
            let promise = URLSession.shared.dataTask(with: request) { data, _, error in
                print("Data is received")
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
//                    try JSONDecoder().decode(FeaturedPlaylistResponse.self, from: data)
//                    completion(.success(result))
                    print(result)
//                    print("SUCCESS")
                } catch {
                      
//                    print("ERROR DESCRIPTION: \(error)")
//                    completion(.failure(error))
                }
                
            }
            promise.resume()
        }
    }
    
    public func getRecommendedGenres(completion: @escaping (Result<RecommendedGenresResponse , Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIReq + "/recommendations/available-genre-seeds"), type: .GET) { request in
            
            let promise = URLSession.shared.dataTask(with: request) { data, _, error in
                print("Data is received")
                
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(RecommendedGenresResponse.self, from: data)
                    print(result)
                    completion(.success(result)) 
                } catch {
                    print("ERROR DESCRIPTION: \(error)")
                    completion(.failure(error))
                }
                
            }
            promise.resume()
        }
    }
    
    private func createRequest(
        with url: URL?,
        type: HTTPMethod,
        completion: @escaping (URLRequest) -> Void) {
        
        AuthManager.shared.withValidToken { token in
            
            guard let apiURL = url else { return }
            
            var request = URLRequest(url: apiURL)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpMethod = type.rawValue
            request.timeoutInterval = 30
            completion(request)
        }
    }
    
    
    
}


