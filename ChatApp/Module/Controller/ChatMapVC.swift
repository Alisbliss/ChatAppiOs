//
//  ChatMapVC.swift
//  ChatApp
//
//  Created by Алеся Афанасенкова on 03.03.2026.
//

import UIKit
import GoogleMaps

protocol ChatMapDelegate: AnyObject {
    func didTapLocation(lat: String, lng: String)
}

class ChatMapVC: UIViewController {
    
    weak var delegate: ChatMapDelegate?
    private let mapView = GMSMapView()
    private var location: CLLocationCoordinate2D?
    private lazy var marker = GMSMarker()
    
    private lazy var sendLocationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send Location", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.tintColor = .white
        button.backgroundColor = .red
        button.setDimensions(height: 50, width: 150)
        button.layer.cornerRadius = 15
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handleSendButton), for: .touchUpInside)
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        configureMapView()
        view.backgroundColor = .white
    }
    private func configure() {
        title = "Select Location"
    
        view.addSubview(mapView)
        
        mapView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: view.leftAnchor,
            bottom: view.bottomAnchor,
            right: view.rightAnchor
        )
        view.addSubview(sendLocationButton)
        sendLocationButton.centerX(inView: view)
        sendLocationButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingBottom: 20)
        
    }
    
    private func configureMapView() {
        FLocationManager.shared.start { [weak self] info in
            guard let self else { return }
            self.location = CLLocationCoordinate2D(latitude: info.latitude ?? 0.0, longitude: info.longitude ?? 0.0)
            self.mapView.delegate = self
            self.mapView.isMyLocationEnabled = true
            self.mapView.settings.myLocationButton = true
            
            guard let location else { return }
            self.updateCamers(location: location)
            FLocationManager.shared.stop()
        }
    }
    
    func updateCamers(location: CLLocationCoordinate2D) {
        self.location = location
        self.mapView.camera = GMSCameraPosition(target: location, zoom: 15)
        self.mapView.animate(toLocation: location)
        
        marker.map = nil
        marker = GMSMarker(position: location)
        marker.map = mapView
    }
    
    @objc func handleSendButton() {
        guard let lat = location?.latitude else { return }
        guard let lng = location?.longitude else { return }
        delegate?.didTapLocation(lat: "\(lat)", lng: "\(lng)")
    }
}

extension ChatMapVC: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        updateCamers(location: position.target)
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        updateCamers(location: coordinate)
    }
}
