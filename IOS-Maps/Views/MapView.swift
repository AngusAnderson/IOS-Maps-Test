import SwiftUI
import MapKit

struct MapView: View {
    let cameraPosition: MapCameraPosition = .region(.init(center: .init(latitude: 37.3346, longitude: -122.0090), latitudinalMeters: 1300, longitudinalMeters: 1300))
    
    let locationManager = CLLocationManager()
    
    @State private var lookAroundScene: MKLookAroundScene?
    @State private var isShowingLookAround = false
    @State private var route: MKRoute?
    
    var body: some View {
        Map(initialPosition: cameraPosition) {
            
            Annotation("Apple Visitor Centre", coordinate: .appleVisitorCentre, anchor: .center) {
                Image(systemName: "apple.logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.white)
                    .frame(width: 20, height: 20)
                    .padding(7)
                    .background(.pink.gradient, in: .circle)
                    .contextMenu {
                        Button("Open Look Around", systemImage: "binoculars") {
                            Task { lookAroundScene = await getLookAroundScene(from: .appleVisitorCentre) }
                                guard lookAroundScene != nil else { return }
                                isShowingLookAround = true
                        }
                        Button("Get Directions", systemImage: "arrow.turn.down.right") {
                            getDirections(to: .appleVisitorCentre)
                        }
                    }
            }
            
            Annotation("Panama Park", coordinate: .panamaPark, anchor: .center) {
                Image(systemName: "tree.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.white)
                    .frame(width: 20, height: 20)
                    .padding(7)
                    .background(.green.gradient, in: .circle)
                    .contextMenu {
                        Button("Open Look Around", systemImage: "binoculars") {
                            Task { lookAroundScene = await getLookAroundScene(from: .panamaPark) }
                                guard lookAroundScene != nil else { return }
                                isShowingLookAround = true
                        }
                        Button("Get Directions", systemImage: "arrow.turn.down.right") {
                            getDirections(to: .panamaPark)
                        }
                    }
            }
            
            Annotation("Smithstone", coordinate: .smithstone, anchor: .center) {
                Image(systemName: "house.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.white)
                    .frame(width: 20, height: 20)
                    .padding(7)
                    .background(.red.gradient, in: .circle)
                    .contextMenu {
                        Button("Open Look Around", systemImage: "binoculars") {
                            Task { lookAroundScene = await getLookAroundScene(from: .smithstone) }
                                guard lookAroundScene != nil else { return }
                                isShowingLookAround = true
                        }
                        Button("Get Directions", systemImage: "arrow.turn.down.right") {
                            getDirections(to: .smithstone)
                        }
                    }
            }
            UserAnnotation()
            
            if let route {
                MapPolyline(route)
                    .stroke(Color.pink, lineWidth: 4)
            }
            
            
        }
        .onAppear {
            locationManager.requestWhenInUseAuthorization()
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapPitchToggle()
            MapScaleView()
        }
        .mapStyle(.standard)
        .lookAroundViewer(isPresented: $isShowingLookAround, initialScene: lookAroundScene)
    }
    
    func getLookAroundScene(from coordinate: CLLocationCoordinate2D) async -> MKLookAroundScene? {
        do {
            return try await MKLookAroundSceneRequest(coordinate: coordinate).scene
        } catch {
            print("Cannot retrieve look around scene: \(error.localizedDescription)")
            return nil
        }
    }
    
    func getUserLocation() async -> CLLocationCoordinate2D? {
        let updates = CLLocationUpdate.liveUpdates()
        
        do {
            let update = try await updates.first { $0.location?.coordinate != nil }
            return update?.location?.coordinate
        } catch {
            print("Cannot get the user location")
            return nil
        }
    }
    
    func getDirections(to destination: CLLocationCoordinate2D) {
        Task {
            guard let userLocation = await getUserLocation() else { return }
            
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: .init(coordinate: userLocation))
            request.destination = MKMapItem(placemark: .init(coordinate: destination))
            request.transportType = .automobile
            
            do {
                let directions = try await MKDirections(request: request).calculate()
                route = directions.routes.first
            } catch {
                print("Show error")
            }
        }
    }
}

extension CLLocationCoordinate2D {
    static let appleHQ = CLLocationCoordinate2D(latitude: 37.3346, longitude: -122.0090)
    static let appleVisitorCentre = CLLocationCoordinate2D(latitude: 37.332753, longitude: -122.005372)
    static let panamaPark = CLLocationCoordinate2D(latitude: 37.347730, longitude: -122.018715)
    static let smithstone = CLLocationCoordinate2D(latitude: 55.948271, longitude: -4.042645)
    
}
