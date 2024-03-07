//
//  HotspotModel.swift
//  Conditional Reminder App
//
//  Created by Marlene on 06.03.24.
//

import CoreLocation
import Foundation
import CoreData

struct Hotspot: Identifiable {
    let id: UUID
    let name: String
    let location: CLLocationCoordinate2D
    
    init(id: UUID = UUID(), name: String, location: CLLocationCoordinate2D) {
        self.id = id
        self.name = name
        self.location = location
    }
    
    init(hotspotItem: HotspotItem) {
        self.id = hotspotItem.uuid ?? UUID()
        self.name = hotspotItem.name ?? ""
        self.location = CLLocationCoordinate2D(latitude: hotspotItem.latitude, longitude: hotspotItem.longitude)
    }
}

extension Hotspot {
    func toHotspotItem(context: NSManagedObjectContext) -> HotspotItem {
        let hotspotItem = HotspotItem(context: context)
        hotspotItem.uuid = self.id
        hotspotItem.name = self.name
        hotspotItem.latitude = self.location.latitude
        hotspotItem.longitude = self.location.longitude
        return hotspotItem
    }
}
