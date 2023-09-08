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
    
    var mapVcDelegate: MapViewControllerDelegate?
    var place = Place()
    var annotationIdentifire = "annotationIdentifire"
    var incomeSegueIdentifire = ""
    var placeCoordinate: CLLocationCoordinate2D?
    
    let locationManager = CLLocationManager()
    let metersForShowRegion = 10000.0
    
    //MARK: - Outlets
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var pinImage: UIImageView!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var goButton: UIButton!
    
    //MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addressLabel.text = " "
        mapView.delegate = self
        setupMapView()
        DispatchQueue.main.async {
            self.checkLocationServices()
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    //MARK: - Actions
    
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        mapVcDelegate?.getPlaceAddress(addressLabel.text!)
        dismiss(animated: true)
    }
    
    
    @IBAction func goButtonPressed() {
        
        getDirections()
    }
    
    @IBAction func viewUserLocation() {
    
        showUserLocation()
    }
    
    @IBAction func cancelButton() {
        dismiss(animated: true)
    }
    
    
    
    //MARK: - Private
    
    private func setupMapView() {
        
        goButton.isHidden = true
        
        if incomeSegueIdentifire == "getLocationPlace" {
            pinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            goButton.isHidden = false
            setupPlacemark()
        }
    }
    
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
            self.placeCoordinate = placemarkLocation.coordinate
            
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
            if incomeSegueIdentifire == "getAdressPlace" { showUserLocation() }
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
    
    private func showUserLocation() {
        
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: metersForShowRegion, longitudinalMeters: metersForShowRegion)
                mapView.setRegion(region, animated: true)
        }
        
    }
    
    private func getDirections() {
        
        guard let location = locationManager.location?.coordinate else {
            showAlertController(title: "Error", message: "Current location is not found")
            return
        }
        
        guard let request = createDirectionRequest(from: location) else {
            showAlertController(title: "Error", message: "Destination is not found")
            return
        }
        
        let directions = MKDirections(request: request)
        directions.calculate { responce, error in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let responce = responce else {
                self.showAlertController(title: "Error", message: "Directions is not avalible")
                return
            }
            
            for route in responce.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInterval = String(format: "%.1f", route.expectedTravelTime / 60)
                
                print("Растояние до места: \(distance) км. Время в пусти составит: \(timeInterval).")
                
            }
        }
    }
    
    private func createDirectionRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        
        guard let destinationCoordinate = placeCoordinate else { return nil }
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        return request
    }
    
    private func getAdress(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
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
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        let center = getAdress(for: mapView)
        let geocoer = CLGeocoder()
        
        geocoer.reverseGeocodeLocation(center) { (placemarks, error) in
            
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
        renderer.strokeColor = .white
        
        return renderer
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAutorization()
    }
}
