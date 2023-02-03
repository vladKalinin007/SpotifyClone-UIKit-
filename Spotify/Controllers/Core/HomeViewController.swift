//
//  ViewController.swift
//  Spotify
//
//  Created by Владислав Калинин on 11.12.2022.
//

import UIKit
import SwiftUI

class HomeViewController: UIViewController {
// MARK: - PROPERTIES
    
    
// MARK: - LIFECICLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .done, target: self, action: #selector(didTapSettings))
        fetchData()
    }

// MARK: - FUNCTIONS
    
    @objc func didTapSettings() {
        let vc  = SettingsViewController()
        vc.title = "Settings"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func fetchData() {

//        APICaller.shared.getNewReleases { result in
//            switch result {
//            case .success(let model): break
//            case .failure(let error): break
//
//
//            }
//        }
        
//        APICaller.shared.getFeaturedPlaylists { result in
//            switch result {
//            case .success(let model): print("Success from HomeViewController")
//            case .failure(let error): print("Error")
//            }
//        }
        
        APICaller.shared.getRecommendedGenres  { result in
            switch result {
                
            case.success(let model):
                
                let genres = model.genres
                var seeds = Set<String>()
                while seeds.count < 5 {
                    if let random = genres.randomElement() {
                        seeds.insert(random)
                    }
                }
                
                APICaller.shared.getRecommendations(genres: seeds) { _ in
                    
                }
                
            case.failure(let error):
                print(error)
                break
            }
        }
    }
    
}

// MARK: - PREVIEW

struct ViewControllerPreview: UIViewControllerRepresentable {
    
    let viewControllerGenerator: () -> UIViewController
    
    init(viewControllerGenerator: @escaping () -> UIViewController) {
        self.viewControllerGenerator = viewControllerGenerator
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        viewControllerGenerator()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

struct ViewControllerProvider: PreviewProvider {
    static var previews: some View {
        ViewControllerPreview {
            HomeViewController()
        }
        .ignoresSafeArea()
    }
}

