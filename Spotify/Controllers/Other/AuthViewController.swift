//
//  AuthViewController.swift
//  Spotify
//
//  Created by Владислав Калинин on 13.12.2022.
//

import UIKit
import WebKit
import SwiftUI

class AuthViewController: UIViewController, WKNavigationDelegate {

    private let webView: WKWebView = {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs
        let webView = WKWebView(frame: .zero, configuration: config)
        return webView
    }()
    
    public var completionHandler: ((Bool) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "sign in "
        view.backgroundColor = .systemBackground
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        guard let url = AuthManager.shared.signInURL  else { return }
        webView.load(URLRequest(url: url))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = view.bounds
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        guard let url = webView.url else { return }
        
        //Exchange code for acccess token
        guard let code = URLComponents(string: url.absoluteString)?.queryItems?.first(where: { $0.name == "code" })?.value else {
            return
        }
        
        webView.isHidden = true
        
        AuthManager.shared.exchangeCodeForToken(code: code) { [weak self] success in
            DispatchQueue.main.async {
                self?.navigationController?.popToRootViewController(animated: true)
                self?.completionHandler?(success)
            }
        }
    }
}

// MARK: - PREVIEW

struct AuthViewControllerRepresentable: UIViewControllerRepresentable {
    
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

struct AuthViewController_Preview: PreviewProvider {
    static var previews: some View {
        AuthViewControllerRepresentable {
            AuthViewController()
        }
        .ignoresSafeArea()
        .background(Color.gray)
    }
}
