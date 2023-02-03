//
//  TabBarViewController.swift
//  Spotify
//
//  Created by Владислав Калинин on 13.12.2022.
//
import SwiftUI
import UIKit

// MARK: - MAIN

class TabBarViewController: UITabBarController {
    
// MARK: - PROPERTIES
    
    
    
// MARK: - LIFECYCLES
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let vc1 = HomeViewController()
        let vc2 = SearchViewController()
        let vc3 = LibraryViewController()
        
        vc1.title = "Browse"
        vc2.title = "Search"
        vc3.title = "Library"
        
        vc1.navigationItem.largeTitleDisplayMode = .always
        vc2.navigationItem.largeTitleDisplayMode = .always
        vc3.navigationItem.largeTitleDisplayMode = .always
        
        let nav1 = UINavigationController(rootViewController: vc1)
        let nav2 = UINavigationController(rootViewController: vc2)
        let nav3 = UINavigationController(rootViewController: vc3)
        
        nav1.navigationBar.tintColor = .label
        nav2.navigationBar.tintColor = .label
        nav3.navigationBar.tintColor = .label
        
        nav1.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house"),
            tag: 1)
        
        nav2.tabBarItem = UITabBarItem(
            title: "Search",
            image: UIImage(systemName: "magnifyingglass"),
            tag: 2)
        
        nav3.tabBarItem = UITabBarItem(
            title: "Library",
            image: UIImage(systemName: "music.note.list"),
            tag: 3)
        
        nav1.navigationBar.prefersLargeTitles = true
        nav2.navigationBar.prefersLargeTitles = true
        nav3.navigationBar.prefersLargeTitles = true
        
        tabBar.tintColor = .label
//        tabBar.backgroundColor = .gray
        
        setViewControllers([nav1, nav2, nav3], animated: false)
        
        
    }
    
// MARK: - FUNCTIONS
    
    
    
}

// MARK: - PREVIEW

struct TabBarViewControllerRepresentable: UIViewControllerRepresentable {
    
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

struct TabBarViewController_Preview: PreviewProvider {
    static var previews: some View {
        TabBarViewControllerRepresentable {
            TabBarViewController()
        }
        .ignoresSafeArea()
        .background(Color.gray)
    }
}


