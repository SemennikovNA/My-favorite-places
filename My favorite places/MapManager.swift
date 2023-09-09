//
//  MapManager.swift
//  My favorite places
//
//  Created by Никита on 09.09.2023.
//

import UIKit
import MapKit

class MapManager {
    
    let locationManager = CLLocationManager()
    
    //MARK: - Properties
    
    private let metersForShowRegion = 500.0
    
    private var placeCoordinate: CLLocationCoordinate2D?
    private var directionsArray: [MKDirections] = []
    
    
    //MARK: - Methods
    
    // Установка маркера для отображения сведений о заведении на карте
    func setupPlacemark(place: Place, mapView: MKMapView) {
        
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
            anotation.title = place.name
            anotation.subtitle = place.type
            
            guard let placemarkLocation = placemark?.location else { return }
            
            anotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinate = placemarkLocation.coordinate
            
            mapView.showAnnotations([anotation], animated: true)
            mapView.selectAnnotation(anotation, animated: true)
        }
        
    }
    
    // Проверка доступности сервисов геолокации
    func checkLocationServices(mapView: MKMapView, segueIdentifire: String, closure: () -> ()) {
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAutorization(mapView: mapView, segueIdentifire: segueIdentifire)
            closure()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlertController(
                    title: "Location services are disable",
                    message: "To enable it to go: Settings ⇾ Privacy ⇾ Location services and Turn  On")
            }
        }
    }
    
    // Проверка авторизации приложения для использования сервисов геолокации
    func checkLocationAutorization(mapView: MKMapView, segueIdentifire: String) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if segueIdentifire == "getAdressPlace" { showUserLocation(mapView: mapView) }
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
            break
        case .authorizedAlways:
            break
        @unknown default:
            print("New case")
        }
    }
    
    // Фокус карты на местоположении пользователя
    func showUserLocation(mapView: MKMapView) {
        
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: metersForShowRegion,
                                            longitudinalMeters: metersForShowRegion)
            mapView.setRegion(region, animated: true)
        }
    }
    
    
    // Построение маршрута от местоположения пользователя до заведения
    func getDirections(for mapView: MKMapView, previousLocation: (CLLocation) -> ()) {
        
        guard let location = locationManager.location?.coordinate else {
            showAlertController(title: "Error", message: "Current location is not found")
            return
        }
        
        locationManager.startUpdatingLocation()
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        
        guard let request = createDirectionsRequest(from: location) else {
            showAlertController(title: "Error", message: "Destination is not found")
            return
        }
        
        let directions = MKDirections(request: request)
        resetMapView(directions: directions, mapView: mapView)
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
                mapView.addOverlay(route.polyline)
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInterval = String(format: "%.1f", route.expectedTravelTime / 60)
                
                print("Растояние до места: \(distance) км. Время в пусти составит: \(timeInterval).")
                
            }
        }
    }
    
    // Настройка запроса для расчета маршрута
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        
        guard let destinationCoordinate = placeCoordinate else { return nil }
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
//        request.requestsAlternateRoutes = true
        
        return request
    }
    
    // Меняю отображаемую зону области карты в соответствии с перемещением пользователя
    func startTrackingUserLocation(for mapView: MKMapView, and location: CLLocation?, closure: (_ currentLocation: CLLocation) -> ()) {
        
        guard let location = location else { return }
        let center = getAdress(for: mapView)
        guard center.distance(from: location) > 50 else { return }
        
        closure(center)
    }
    
    // Сброс всех ранее постороенных маршрутов перед построением нового
    func resetMapView(directions: MKDirections, mapView: MKMapView) {
        
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map {$0.cancel()}
        directionsArray.removeAll()
    }

    
    // Определения центра отображаемой области
    func getAdress(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    // Отображение контроллера с предупреждением
    func showAlertController(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(okAction)
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true)
    }
    
}
