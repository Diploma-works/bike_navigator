//
//  MainViewController.swift
//  mapboxTest
//
//  Created by Artamonov Aleksandr on 07.05.2021.
//

import Mapbox
import Combine
import SnapKit
import SFSafeSymbols
import FloatingPanel
import MapboxSearch

internal class MainViewController: UIViewController {

   internal var saintPetersburgBounds: MGLCoordinateBounds!
   internal var cancellables = Set<AnyCancellable>()
   var viewModel: MainViewModel
   let searchEngine = SearchEngine()
   let categorySearchEngine = CategorySearchEngine()
   var contentVC: SearchViewController!
   var detailsVC: DetailsViewController!
   var routesVC: RoutesViewController!
   var draggingRefreshTimer: Timer?

   lazy var mapView = configure(MGLMapView(frame: view.bounds)) { mapView in
      mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      mapView.setCenter(CLLocationCoordinate2D(latitude: 59.955342, longitude: 30.319171), zoomLevel: 12, animated: false)
      mapView.minimumZoomLevel = 9
      mapView.maximumZoomLevel = 17
      mapView.delegate = self
      mapView.showsUserLocation = true
   }

   private lazy var userLocationButton = configure(RoundedButton()) { button in
      let icon = UIImageView(image: UIImage(systemSymbol: .locationFill))
      icon.tintColor = ApplicationColors.mainCyan
      button.addSubview(icon)
      icon.snp.makeConstraints { make in
         make.center.equalToSuperview()
      }
      button.publisher(for: .touchUpInside)
         .sink { [weak self] in
            self?.centerByUser()
         }
         .store(in: &cancellables)
   }

   lazy var searchFpc = configure(FloatingPanelController()) { fpc in
      fpc.surfaceView.grabberHandle.isHidden = true
      fpc.delegate = self
      fpc.layout = PanelInstrictLayout()
      let appearance = SurfaceAppearance()
      appearance.cornerRadius = 8.0
      fpc.surfaceView.appearance = appearance
      fpc.contentMode = .fitToBounds
   }

   lazy var detailsFpc = configure(FloatingPanelController()) { fpc in
      fpc.surfaceView.grabberHandle.isHidden = true
      fpc.delegate = self
      fpc.layout = DetailsLayout()
      let appearance = SurfaceAppearance()
      appearance.cornerRadius = 8.0
      fpc.surfaceView.appearance = appearance
      fpc.contentMode = .fitToBounds
   }

   lazy var routesFpc = configure(FloatingPanelController()) { fpc in
      fpc.surfaceView.grabberHandle.isHidden = true
      fpc.delegate = self
      fpc.layout = DetailsLayout()
      let appearance = SurfaceAppearance()
      appearance.cornerRadius = 8.0
      fpc.surfaceView.appearance = appearance
      fpc.contentMode = .fitToBounds
   }


   init(viewModel: MainViewModel = MainViewModel()) {
      self.viewModel = viewModel
      super.init(nibName: nil, bundle: nil)
   }

   required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }

   public override func viewDidLoad() {
      super.viewDidLoad()
      let northeast = CLLocationCoordinate2D(latitude: 60.105578, longitude: 30.558123)
      let southwest = CLLocationCoordinate2D(latitude: 59.807874, longitude: 29.644885)
      self.saintPetersburgBounds = MGLCoordinateBounds(sw: southwest, ne: northeast)

      contentVC = SearchViewController(viewModel: SearchViewModel(), textFieldDelegate: self)
      contentVC.textField.addTarget(self, action: #selector(textFieldTextDidChanged), for: .editingChanged)
      contentVC.onSelect = { [weak self] searchSuggestion in
         self?.searchEngine.select(suggestion: searchSuggestion)
      }
      contentVC.onClear = { [weak self] in
         self?.searchFpc.move(to: .tip, animated: true)
      }

      detailsVC = DetailsViewController()
      detailsVC.onDismiss = { [weak self] in
         self?.viewModel.selectedCoordinate = nil
         self?.removeUserPin()
      }
      detailsVC.onRouteTap = { [weak self] in
         self?.buildRoute()
      }

      routesVC = RoutesViewController()
      routesVC.onDismiss = { [weak self] in
         self?.viewModel.selectedCoordinate = nil
         self?.viewModel.routes = nil
         self?.removeUserPin()
         self?.removeRouteLayer()
      }
      routesVC.onRouteTap = { [weak self] active in
         if let routes = self?.viewModel.routes {
            self?.removeRouteLayer()
            self?.createRouteLayer(newRoute: routes.0, oldRoute: routes.1, active: active)
         }
      }


      searchEngine.delegate = self
      addSubviews()
      bind()
   }

   func addSubviews() {
      view.addSubview(mapView)
      mapView.snp.makeConstraints { make in
         make.edges.equalToSuperview()
      }

      view.addSubview(userLocationButton)
      userLocationButton.snp.makeConstraints { make in
         make.width.height.equalTo(40)
         make.leading.equalToSuperview().offset(10)
         make.bottom.equalTo(view.safeArea.bottom).inset(110)
      }

      // Add a single tap gesture recognizer. This gesture requires the built-in MGLMapView tap gestures (such as those for zoom and annotation selection) to fail.
      let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleMapTap(sender:)))
      for recognizer in mapView.gestureRecognizers! where recognizer is UITapGestureRecognizer {
         singleTap.require(toFail: recognizer)
      }
      mapView.addGestureRecognizer(singleTap)
      searchFpc.backdropView.isHidden = true
      searchFpc.set(contentViewController: contentVC)
      searchFpc.addPanel(toParent: self)

      detailsFpc.backdropView.isHidden = true
      detailsFpc.set(contentViewController: detailsVC)

      routesFpc.backdropView.isHidden = true
      routesFpc.set(contentViewController: routesVC)
   }

   func bind() {
      viewModel.parkingAnnotations
         .sink { [weak self] annotations in
            self?.updateParking(with: annotations)
         }
         .store(in: &cancellables)

      viewModel.lanes
         .compactMap { $0 }
         .sink { [weak self] lanes in
            self?.updateLanes(with: lanes)
         }
         .store(in: &cancellables)
   }
}
