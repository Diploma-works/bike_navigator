//
//  DetailsViewController.swift
//  mapboxTest
//
//  Created by Artamonov Aleksandr on 10.05.2021.
//

import UIKit
import Combine
import SnapKit

final class DetailsViewController: UIViewController {

   private var cancellables = Set<AnyCancellable>()

   var onDismiss: (() -> Void)?

   var onRouteTap: (() -> Void)?

   private lazy var label = configure(UILabel()) { label in
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

   private lazy var routeButton = configure(UIButton()) { button in
      button.setTitle("Маршрут", for: .normal)
      button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
      button.layer.cornerRadius = 8
      button.titleLabel?.numberOfLines = 0
      button.titleEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
      button.setBackgroundColor(color: ApplicationColors.mainCyan, forState: .normal)
      button.publisher(for: .touchUpInside)
         .sink { [weak self] in
            self?.dismiss(animated: true, completion: nil)
            self?.onRouteTap?()
         }
         .store(in: &cancellables)
   }

   public func set(title: String) {
      label.text = title
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

      view.addSubview(routeButton)
      routeButton.snp.makeConstraints { make in
         make.top.equalTo(label.snp.bottom).offset(10)
         make.leading.equalToSuperview().offset(10)
         make.height.equalTo(40)
         make.width.equalTo(100)
      }
   }
}
