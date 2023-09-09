//
//  MapViewController.swift
//  My favorite places
//
//  Created by Nikita on 05.09.2023.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewControllerDelegate {
    func getPlaceAddress(_ address: String?)
}

class MapViewController: UIViewController {
    
    //MARK: - Properties
    
    let mapManager = MapManager()
    var mapVcDelegate: MapViewControllerDelegate?
    var place = Place()
    var annotationIdentifire = "annotationIdentifire"
    var incomeSegueIdentifire = ""
    
    var previousLocation: CLLocation? {
        didSet {
            mapManager.startTrackingUserLocation(for: mapView, and: previousLocation) { (currentLocation) in
                self.previousLocation = currentLocation
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.mapManager.showUserLocation(mapView: self.mapView)
                }
            }
        }
    }
    
    
    //MARK: - Outlets
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var pinImage: UIImageView!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var goButton: UIButton!
    
    //MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapManager.locationManager.delegate = self
        addressLabel.text = " "
        mapView.delegate = self
        setupMapView()
    }
    
    //MARK: - Actions
    
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        mapVcDelegate?.getPlaceAddress(addressLabel.text!)
        dismiss(animated: true)
    }
    
    
    @IBAction func goButtonPressed() {
        mapManager.getDirections(for: mapView) { (location) in
            self.previousLocation = location
        }
    }
    
    @IBAction func viewUserLocation() {
        mapManager.showUserLocation(mapView: mapView)
    }
    
    @IBAction func cancelButton() {
        dismiss(animated: true)
    }
    
    
    
    //MARK: - Private
    
    private func setupMapView() {
        
        goButton.isHidden = true
        
        mapManager.checkLocationAutorization(mapView: mapView, segueIdentifire: incomeSegueIdentifire)
        
        if incomeSegueIdentifire == "getLocationPlace" {
            mapManager.setupPlacemark(place: place, mapView: mapView)
            pinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            goButton.isHidden = false
        }
    }
}

//MARK: - Extensions

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocation) else { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifire) as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifire)
            annotationView?.canShowCallout = true
        }
        
        let imageData = place.imageData
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.image = UIImage(data: imageData)
        
        annotationView?.leftCalloutAccessoryView = imageView
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        let center = mapManager.getAdress(for: mapView)
        let geocoder = CLGeocoder()
        
        if incomeSegueIdentifire == "getLocationPlace" && previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.mapManager.showUserLocation(mapView: mapView)
            }
        }
        
        geocoder.cancelGeocode()
        
        geocoder.reverseGeocodeLocation(center) { (placemarks, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first
            let cityName = placemark?.locality
            let streetName = placemark?.thoroughfare
            let numberBuild = placemark?.subThoroughfare
            
            DispatchQueue.main.async {
                if cityName != nil && streetName != nil && numberBuild != nil {
                    self.addressLabel.text = "\(cityName!), \(streetName!), \(numberBuild!)"
                } else if cityName != nil && streetName != nil {
                    self.addressLabel.text = "\(cityName!), \(streetName!)"
                } else if cityName != nil {
                    self.addressLabel.text = "\(cityName!)"
                } else {
                    self.addressLabel.text = " "
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .green
        
        return renderer
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        mapManager.checkLocationAutorization(mapView: mapView, segueIdentifire: incomeSegueIdentifire)
    }
}
