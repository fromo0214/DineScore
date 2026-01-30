//
//  LocationManager.swift
//  DineScore
//
//  Location service to handle Core Location permissions and functionality
//

import Foundation
import CoreLocation
import Combine
import os.log

@MainActor
final class LocationManager: NSObject, ObservableObject {
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var lastLocation: CLLocation?
    @Published var locationError: Error?
    
    private let locationManager = CLLocationManager()
    private let logger = Logger(subsystem: "com.dinescore.app", category: "LocationManager")
    
    override init() {
        super.init()
        locationManager.delegate = self
        // Use kCLLocationAccuracyHundredMeters for better battery efficiency
        // This is sufficient for finding nearby restaurants
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        authorizationStatus = locationManager.authorizationStatus
    }
    
    /// Request location permission from the user
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// Start updating location
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    /// Stop updating location
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            authorizationStatus = manager.authorizationStatus
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            lastLocation = locations.last
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            locationError = error
            logger.error("Location manager error: \(error.localizedDescription)")
        }
    }
}
