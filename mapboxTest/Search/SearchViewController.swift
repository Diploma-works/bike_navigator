//
//  SearchViewController.swift
//  mapboxTest
//
//  Created by Artamonov Aleksandr on 08.05.2021.
//

import UIKit
import Combine
import MapboxSearch

final class SearchViewController: UIViewController {

   private var cancellable = Set<AnyCancellable>()
   var viewModel: SearchViewModel
   private var dataSource: UITableViewDiffableDataSource<SearchSection, SearchItem>?

   var textFieldDelegate: UITextFieldDelegate
   var onSelect: ((MapboxSearch.SearchSuggestion) -> ())?
   var onClear: (() -> Void)?

   init(viewModel: SearchViewModel, textFieldDelegate: UITextFieldDelegate) {
      self.textFieldDelegate = textFieldDelegate
      self.viewModel = viewModel
      super.init(nibName: nil, bundle: nil)
   }
   
   required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }

   public lazy var textField = configure(RoundedTextField()) { textField in
      textField.attributedPlaceholder = NSAttributedString(string: "Поиск адресов и мест",
                                                           attributes: [NSAttributedString.Key.foregroundColor: ApplicationColors.hintTextColor])
      textField.delegate = textFieldDelegate
      textField.font = UIFont.systemFont(ofSize: 20)
      textField.textColor = .white
      textField.tintColor = ApplicationColors.hintTextColor
      textField.backgroundColor = ApplicationColors.separatorColor
      textField.onClear = { [weak self] in
         self?.onClear?()
         var snapshot = NSDiffableDataSourceSnapshot<SearchSection, SearchItem>()
         snapshot.appendSections([.main])
         snapshot.appendItems([])
         self?.dataSource?.apply(snapshot, animatingDifferences: false)
      }
      textField.modifyClearButtonWithImage(image: UIImage(systemSymbol: .deleteLeftFill))
   }

   lazy var tableView: UITableView = configure(UITableView(frame: .zero)) {
      $0.contentInset = .init(top: 0, left: 0, bottom: 40.0, right: 0)
      $0.showsVerticalScrollIndicator = false
      $0.delegate = self
      $0.backgroundColor = .clear
      $0.separatorColor = ApplicationColors.separatorColor
      $0.register(SearchItemCell.self, forCellReuseIdentifier: SearchItemCell.identifier)
   }

   override func viewDidLoad() {
      super.viewDidLoad()
      view.backgroundColor = ApplicationColors.mainBlack
      dataSource = makeDataSource()


      view.addSubview(textField)
      textField.snp.makeConstraints { make in
         make.top.leading.equalToSuperview().offset(10)
         make.trailing.equalToSuperview().inset(10)
      }

      view.addSubview(tableView)
      tableView.snp.makeConstraints { make in
         make.top.equalTo(textField.snp.bottom).offset(10)
         make.leading.equalToSuperview().offset(10)
         make.trailing.equalToSuperview().inset(10)
         make.bottom.equalToSuperview()
      }

      viewModel.searchResults
         .sink { [unowned self] items in
            var snapshot = NSDiffableDataSourceSnapshot<SearchSection, SearchItem>()
            snapshot.appendSections([.main])
            snapshot.appendItems(items.map { SearchItem(searchSuggestion: $0) })
            self.dataSource?.apply(snapshot, animatingDifferences: false)
         }
         .store(in: &cancellable)
   }

   private func makeDataSource() -> UITableViewDiffableDataSource<SearchSection, SearchItem> {
      let dataSource = UITableViewDiffableDataSource<SearchSection, SearchItem> (tableView: tableView) { (tableView, indexPath, item) in
         let cell = tableView.dequeueReusableCell(withIdentifier: SearchItemCell.identifier, for: indexPath) as? SearchItemCell
         cell?.set(title: item.name)
         return cell
      }
      dataSource.defaultRowAnimation = .fade
      return dataSource
   }
}


extension SearchViewController: UITableViewDelegate {
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      tableView.deselectRow(at: indexPath, animated: true)
      guard let searchResult = dataSource?.itemIdentifier(for: indexPath) else { return }
      viewModel.searchResults.send([])
      textField.text = ""
      onSelect?(searchResult.searchSuggestion)
   }
}
