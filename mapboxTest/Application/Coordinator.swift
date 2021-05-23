//
//  Coordinator.swift
//  mapboxTest
//
//  Created by Artamonov Aleksandr on 14.05.2021.
//

import UIKit

protocol Coordinator {
   func start()
}

class ApplicationCoordinator: Coordinator {
   let window: UIWindow
   let rootViewController: UINavigationController

   init(window: UIWindow) {
      self.window = window
      rootViewController = UINavigationController()
      rootViewController.navigationBar.isHidden = true
   }

   func start() {
      window.rootViewController = rootViewController
      let mainViewController = MainViewController()
      rootViewController.pushViewController(mainViewController, animated: false)
      window.makeKeyAndVisible()
   }
}
