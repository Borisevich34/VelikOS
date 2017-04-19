//
//  PBMapView.swift
//  VelikOSX
//
//  Created by Pavel Borisevich on 19.04.17.
//  Copyright © 2017 Pavel Borisevich. All rights reserved.
//

import MapKit

class PBMapView: MKMapView {

    var isPositionChanged : Bool = false
    
    var compasFrame : CGRect!
    var labelFrame : CGRect!
    var zoomFrame : CGRect!
    
    override func layout() {
        super.layout()
        
        if !isPositionChanged {
            if let compassView = self.subviews.filter({ $0.className == "MKCompassView" }).first {
                compasFrame = compassView.frame
                compasFrame.origin.x = frame.size.width - compasFrame.origin.x - compasFrame.size.width
                compassView.frame = compasFrame
            }
            if let attributionLabel = self.subviews.filter({ $0.className == "MKAttributionLabel" }).first {
                labelFrame = attributionLabel.frame
                labelFrame.origin.x = frame.size.width - labelFrame.origin.x - labelFrame.size.width
                attributionLabel.frame = labelFrame
            }
            if let zoomSegmentControl = self.subviews.filter({ $0.className == "MKZoomSegmentedControl" }).first {
                zoomFrame = zoomSegmentControl.frame
                zoomFrame.origin.x = frame.size.width - zoomFrame.origin.x - zoomFrame.size.width
                zoomSegmentControl.frame = zoomFrame
            }
            isPositionChanged = true
        }
        if let compassView = self.subviews.filter({ $0.className == "MKCompassView" }).first {
            compassView.frame = compasFrame
        }
        if let attributionLabel = self.subviews.filter({ $0.className == "MKAttributionLabel" }).first {
            attributionLabel.frame = labelFrame
        }
        if let zoomSegmentControl = self.subviews.filter({ $0.className == "MKZoomSegmentedControl" }).first {
            zoomSegmentControl.frame = zoomFrame
        }

    }
}
