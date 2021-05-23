//
//  RoutesViewController.swift
//  mapboxTest
//
//  Created by Artamonov Aleksandr on 11.05.2021.
//

import UIKit
import Combine
import SnapKit

enum RouteType {
   case safe
   case short
}

final class RoutesViewController: UIViewController {

   private var cancellables = Set<AnyCancellable>()

   var onDismiss: (() -> Void)?

   var onRouteTap: ((RouteType) -> Void)?

   private lazy var label = configure(UILabel()) { label in
      label.text = "Возможные маршруты"
      label.textColor = .white
      label.numberOfLines = 0
      label.font = UIFont.systemFont(ofSize: 20)
   }

   private lazy var closeButton = configure(UIButton()) { button in
      button.setImage(UIImage(named: "close"), for: .normal)
      button.publisher(for: .touchUpInside)
         .sink { [weak self] in
            self?.dismiss(animated: true, completion: nil)
            self?.onDismiss?()
         }
         .store(in: &cancellables)
   }

   private lazy var route1Button = configure(UIButton()) { button in
      button.setTitle("Безопасный", for: .normal)
      button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
      button.layer.cornerRadius = 8
      button.titleLabel?.numberOfLines = 0
      button.titleEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
      button.setBackgroundColor(color: ApplicationColors.mainCyan, forState: .normal)
      button.publisher(for: .touchUpInside)
         .sink { [weak self] in
            self?.changeActiveButton(active: .safe)
         }
         .store(in: &cancellables)
   }

   private lazy var route2Button = configure(UIButton()) { button in
      button.setTitle("Оптимальный", for: .normal)
      button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
      button.layer.cornerRadius = 8
      button.titleLabel?.numberOfLines = 0
      button.titleEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
      button.setBackgroundColor(color: ApplicationColors.darkOrange, forState: .normal)
      button.publisher(for: .touchUpInside)
         .sink { [weak self] in
            self?.changeActiveButton(active: .short)
         }
         .store(in: &cancellables)
   }

   func changeActiveButton(active: RouteType) {
      if active == .safe {
         route1Button.setBackgroundColor(color: ApplicationColors.mainCyan, forState: .normal)
         route2Button.setBackgroundColor(color: ApplicationColors.darkOrange, forState: .normal)
      } else {
         route2Button.setBackgroundColor(color: ApplicationColors.mainOrange, forState: .normal)
         route1Button.setBackgroundColor(color: ApplicationColors.darkCyan, forState: .normal)
      }
      onRouteTap?(active)
   }

   override func viewDidLoad() {
      super.viewDidLoad()
      view.backgroundColor = ApplicationColors.mainBlack


      view.addSubview(label)
      label.snp.makeConstraints { make in
         make.top.leading.equalToSuperview().offset(10)
      }

      view.addSubview(closeButton)
      closeButton.snp.makeConstraints { make in
         make.size.equalTo(35)
         make.top.equalToSuperview()
         make.trailing.equalToSuperview()
         make.leading.greaterThanOrEqualTo(label.snp.trailing).offset(10)
      }

      view.addSubview(route1Button)
      route1Button.snp.makeConstraints { make in
         make.top.equalTo(label.snp.bottom).offset(10)
         make.leading.equalToSuperview().offset(10)
         make.height.equalTo(40)
         make.width.equalTo(150)
      }

      view.addSubview(route2Button)
      route2Button.snp.makeConstraints { make in
         make.top.equalTo(label.snp.bottom).offset(10)
         make.leading.equalTo(route1Button.snp.trailing).offset(10)
         make.height.equalTo(40)
         make.width.equalTo(150)
      }
   }
}
