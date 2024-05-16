import SwiftUI
import MapKit

struct LocationView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 50.928139, longitude: 4.429381),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var userLocation: UserLocation?
    @State private var extraMarker: CustomAnnotation?

    var body: some View {
        VStack {
            Map(coordinateRegion: $region, showsUserLocation: true, userTrackingMode: .constant(.follow), annotationItems: [extraMarker].compactMap { $0 }) { location in
                MapMarker(coordinate: location.coordinate, tint: .red)
            }
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                setToUserLocation()
                addExtraMarker()
            }
            
            HStack {
                Button(action: {
                    zoomIn()
                }) {
                    Image(systemName: "plus")
                }
                .padding()
                
                Button(action: {
                    zoomOut()
                }) {
                    Image(systemName: "minus")
                }
                .padding()
                
                Button(action: {
                    setToUserLocation()
                }) {
                    Image(systemName: "location")
                }
                .padding()
            }
        }
        .onAppear {
            setToUserLocation()
        }
    }
    

    private func setToUserLocation() {
        userLocation = UserLocation(coordinate: CLLocationCoordinate2D(latitude: 50.928139, longitude: 4.429381))
        
        if let userLocation = userLocation {
            region = MKCoordinateRegion(center: userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        }
    }
    

    private func zoomIn() {
        region.span.latitudeDelta *= 0.8
        region.span.longitudeDelta *= 0.8
    }
    
   
    private func zoomOut() {
        region.span.latitudeDelta *= 1.2
        region.span.longitudeDelta *= 1.2
    }
    

    private func addExtraMarker() {
        extraMarker = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: 50.934011, longitude: 4.428685))
    }
}

struct LocationView_Previews: PreviewProvider {
    static var previews: some View {
        LocationView()
    }
}

struct UserLocation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}


struct CustomAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}
