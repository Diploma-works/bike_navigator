//
//  SearchItemCell.swift
//  mapboxTest
//
//  Created by Artamonov Aleksandr on 09.05.2021.
//

import UIKit
import SnapKit

final class SearchItemCell: UITableViewCell, CellIdentifiable {

   var titleLabel = configure(UILabel()) { label in
      label.numberOfLines = 0
      label.textColor = .white
   }

   override func prepareForReuse() {
      super.prepareForReuse()
   }

   override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
      super.init(style: style, reuseIdentifier: reuseIdentifier)
      contentView.addSubview(titleLabel)
      contentView.backgroundColor = ApplicationColors.mainBlack

      titleLabel.snp.makeConstraints { make in
         make.top.leading.equalToSuperview().offset(16.0)
         make.bottom.trailing.equalToSuperview().inset(16.0)
      }
   }

   required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }

   func set(title: String) {
      titleLabel.text = title
   }
}
