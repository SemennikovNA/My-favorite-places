//
//  MapViewController.swift
//  My favorite places
//
//  Created by Nikita on 05.09.2023.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    //MARK: - Properties
    
    var place = Place()
    var annotationIdentifire = "annotationIdentifire"
    let locationManager = CLLocationManager()
    let metersForShowRegion = 5000.0
    
    //MARK: - Outlets
    
    @IBOutlet var mapView: MKMapView!
    
    //MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupPlacemark()
        
        DispatchQueue.main.async {
            self.checkLocationServices()
        }
    }
    
    //MARK: - Actions

    @IBAction func viewUserLocation() {
        
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: metersForShowRegion, longitudinalMeters: metersForShowRegion)
                mapView.setRegion(region, animated: true)
        }
        
    }
    
    @IBAction func cancelButton() {
        dismiss(animated: true)
    }
    
    //MARK: - Private
    
    private func setupPlacemark() {
        
        guard let location = place.location else { return }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { placemarks, error in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            
            let anotation = MKPointAnnotation()
            anotation.title = self.place.name
            anotation.subtitle = self.place.type
            
            guard let placemarkLocation = placemark?.location else { return }
            
            anotation.coordinate = placemarkLocation.coordinate
            
            self.mapView.showAnnotations([anotation], animated: true)
            self.mapView.selectAnnotation(anotation, animated: true)
        }
        
    }
    
    private func checkLocationServices() {
        
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAutorization()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlertController(
                    title: "Location services are disable",
                    message: "To enable it to go: Settings ⇾ Privacy ⇾ Location services and Turn  On")
            }
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func checkLocationAutorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            break
        case .denied:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlertController(
                    title: "Location services are disable",
                    message: "To enable it to go: Settings ⇾ Privacy ⇾ Location services and Turn  On")
            }
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlertController(
                    title: "Location services are disable",
                    message: "To enable it to go: Settings ⇾ Privacy ⇾ Location services and Turn  On")
            }
            break
        case .authorizedAlways:
            break
        @unknown default:
            print("New case")
        }
    }
    
    private func showAlertController(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
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
    
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAutorization()
    }
}
