//
// Copyright 2014 ESRI
//
// All rights reserved under the copyright laws of the United States
// and applicable international laws, treaties, and conventions.
//
// You may freely redistribute and use this sample code, with or
// without modification, provided you include the original copyright
// notice and use restrictions.
//
// See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
//

import UIKit
import ArcGIS

//let kTiledMapServiceUrl = "http://services.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer"
let kTiledMapServiceUrl = "http://prod.gis.msu.edu/arcgis/rest/services/basemap/osm/MapServer"
//let kRouteTaskUrl = "http://sampleserver3.arcgisonline.com/ArcGIS/rest/services/Network/USA/NAServer/Route"
let kRouteTaskUrl = "https://prod.gis.msu.edu/arcgis/rest/services/routing/ped_network/NAServer/Route"

class ArcGisMapViewController: UIViewController, AGSRouteTaskDelegate, AGSLayerCalloutDelegate, UIAlertViewDelegate {
    
    var destinationBuilding: Building!
    var routingFlag: Bool = false
    
    @IBOutlet weak var mapView:AGSMapView!
    @IBOutlet weak var directionsBannerView:UIView!
    @IBOutlet weak var directionsLabel:UILabel!
    
    @IBOutlet weak var prevBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    
    var graphicsLayer:AGSGraphicsLayer!
    var sketchLayer:AGSSketchGraphicsLayer!
    var routeTask:AGSRouteTask!
    var routeTaskParams:AGSRouteTaskParameters!
    var currentStopGraphic:AGSStopGraphic!
    var selectedGraphic:AGSGraphic!
    var currentDirectionGraphic:AGSDirectionGraphic!
    var stopCalloutView:UIView!
    var routeResult:AGSRouteResult!
    
    var numStops:Int = 0
    var numBarriers:Int = 0
    var directionIndex:Int = 0
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load a tiled map service
        let mapUrl = NSURL(string: kTiledMapServiceUrl)
        let tiledLyr = AGSTiledMapServiceLayer(URL: mapUrl)
        self.mapView.addMapLayer(tiledLyr, withName:"Tiled Layer")
        
        // zoom to some location (this is San Francisco)
        let sr = AGSSpatialReference(WKID: 102100)
        
        let env = AGSEnvelope(xmin: -9404607.452300,
            ymin:5269872.926800,
            xmax:-9403405.987100,
            ymax:5270274.406500,
            spatialReference:sr)
        self.mapView.zoomToEnvelope(env, animated:true)
        
        // Setup the route task
        let routeTaskUrl = NSURL(string: kRouteTaskUrl)
        self.routeTask = AGSRouteTask(URL: routeTaskUrl)
        
        // assign delegate to this view controller
        self.routeTask.delegate = self
        
        // kick off asynchronous method to retrieve default parameters
        // for the route task
        self.routeTask.retrieveDefaultRouteTaskParameters()
        
        // add sketch layer to the map
        let mp = AGSMutablePoint(spatialReference: AGSSpatialReference.webMercatorSpatialReference())
        self.sketchLayer = AGSSketchGraphicsLayer(geometry: mp)
        self.mapView.addMapLayer(self.sketchLayer, withName:"sketchLayer")
        
        //Register for "Geometry Changed" notifications
        //We want to enable/disable UI elements when sketch geometry is modified
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"respondToGeomChanged:", name:AGSSketchGraphicsLayerGeometryDidChangeNotification, object:nil)
        
        
        // add graphics layer
        self.graphicsLayer = AGSGraphicsLayer()
        self.mapView.addMapLayer(self.graphicsLayer, withName:"Route results")
        
        // set the callout delegate so we can display callouts
        self.graphicsLayer.calloutDelegate = self
        
        // create a custom callout view using a button with an image
        // this is to remove stops after we add them to the map
        let removeStopBtn = UIButton.buttonWithType(.Custom) as UIButton
        removeStopBtn.frame = CGRectMake(0, 0, 24, 24)
        removeStopBtn.setImage(UIImage(named: "remove24.png"), forState:.Normal)
        removeStopBtn.addTarget(self, action: "removeStopClicked", forControlEvents: .TouchUpInside)
        self.stopCalloutView = removeStopBtn
        
        // update our banner
        self.updateDirectionsLabel("No Direction")
        
        //Listen to KVO notifications for map gps's location property
        self.mapView.locationDisplay.addObserver(self, forKeyPath: "location", options: .New, context: nil)
    
        self.mapView.locationDisplay.autoPanMode = .Default
        
        self.mapView.locationDisplay.wanderExtentFactor = 0.75
        
        //Start the map's gps if it isn't enabled already
        if !self.mapView.locationDisplay.dataSourceStarted {
            self.mapView.locationDisplay.startDataSource()
        }
        
        self.mapView.addObserver(self, forKeyPath: "mapAnchor", options: .New, context: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - AGSRouteTaskDelegate
    
    //
    // we got the default parameters from the service
    //
    func routeTask(routeTask: AGSRouteTask!, operation op: NSOperation!, didRetrieveDefaultRouteTaskParameters routeParams: AGSRouteTaskParameters!) {
        self.routeTaskParams = routeParams
        readyToRoute()
        
    }
    
    //
    // an error was encountered while getting defaults
    //
    func routeTask(routeTask: AGSRouteTask!, operation op: NSOperation!, didFailToRetrieveDefaultRouteTaskParametersWithError error: NSError!) {
        // Create an alert to let the user know the retrieval failed
        // Click Retry to attempt to retrieve the defaults again
        UIAlertView(title: "Error", message: "Failed to retrieve default route parameters", delegate: self, cancelButtonTitle: "Ok").show()
    }
    
    
    //
    // route was solved
    //
    func routeTask(routeTask: AGSRouteTask!, operation op: NSOperation!, didSolveWithResult routeTaskResult: AGSRouteTaskResult!) {
        
        // update our banner with status
        self.updateDirectionsLabel("Routing completed")
        
        // we know that we are only dealing with 1 route...
        self.routeResult = routeTaskResult.routeResults.last as AGSRouteResult
        if self.routeResult != nil {
            // symbolize the returned route graphic
            self.routeResult.routeGraphic.symbol = self.routeSymbol()
            
            // add the route graphic to the graphic's layer
            self.graphicsLayer.addGraphic(self.routeResult.routeGraphic)
            
            // enable the next button so the user can traverse directions
            self.nextBtn.enabled = true
            
            // remove the stop graphics from the graphics layer
            // careful not to attempt to mutate the graphics array while
            // it is being enumerated
            //TODO: test this functionality
            let graphics = self.graphicsLayer.graphics
            for g in graphics {
                if g is AGSStopGraphic {
                    self.graphicsLayer.removeGraphic(g as AGSStopGraphic)
                }
            }
            
            // add the returned stops...it's possible these came back in a different order
            // because we specified findBestSequence
            for sg in self.routeResult.stopGraphics as [AGSStopGraphic] {
                
                // get the sequence from the attribetus
                var exists:ObjCBool = false
                let sequence = sg.attributeAsIntegerForKey("Sequence", exists: &exists)
                
                // create a composite symbol using the sequence number
                sg.symbol = self.stopSymbolWithNumber(sequence)
                
                // add the graphic
                self.graphicsLayer.addGraphic(sg)
            }
        }
    }
    
    //
    // solve failed
    //
    func routeTask(routeTask: AGSRouteTask!, operation op: NSOperation!, didFailSolveWithError error: NSError!) {
        self.updateDirectionsLabel("Routing failed")
        
        // the solve route failed...
        // let the user know
        UIAlertView(title: "Solve Route Failed", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "Ok").show()
        println("Solve Route Failed :: \(error)")
    }
    
    //MARK: - UIAlertViewDelegate
    
    //
    // If the user clicks 'Retry' then we should attempt to retrieve the defaults again
    //
    func alertView(alertView: UIAlertView!, clickedButtonAtIndex buttonIndex: Int) {
        // see which button was clicked, Ok or Retry
        // Ok		index 0
        // Retry	index 1
        switch buttonIndex {
        case 1:  // Retry
            self.routeTask.retrieveDefaultRouteTaskParameters()
        default:
            break;
        }
    }
    
    //MARK: - Misc
    
    func respondToGeomChanged(notification:NSNotification) {
        //Enable/disable UI elements appropriately
    }
    
    //
    // create a composite symbol with a number
    //
    func stopSymbolWithNumber(stopNumber:Int) -> AGSCompositeSymbol {
        let cs = AGSCompositeSymbol()
        
        // create outline
        let sls = AGSSimpleLineSymbol()
        sls.color = UIColor.blackColor()
        sls.width = 2
        sls.style = .Solid
        
        // create main circle
        let sms = AGSSimpleMarkerSymbol()
        sms.color = UIColor.greenColor()
        sms.outline = sls
        sms.size = CGSizeMake(20, 20)
        sms.style = .Circle
        cs.addSymbol(sms)
        
        //    // add number as a text symbol
        let ts = AGSTextSymbol(text: "\(stopNumber)", color: UIColor.blackColor())
        ts.vAlignment = .Middle
        ts.hAlignment = .Center
        ts.fontSize	= 16
        cs.addSymbol(ts)
        
        return cs
    }
    
    //
    // default symbol for the barriers
    //
    func barrierSymbol() -> AGSCompositeSymbol {
        let cs = AGSCompositeSymbol()
        
        let sls = AGSSimpleLineSymbol()
        sls.color = UIColor.redColor()
        sls.style = .Solid
        sls.width = 2
        
        let sfs = AGSSimpleFillSymbol()
        sfs.outline = sls
        sfs.style = .Solid
        sfs.color = UIColor.redColor().colorWithAlphaComponent(0.45)
        cs.addSymbol(sfs)
        
        //	AGSTextSymbol *ts = [[[AGSTextSymbol alloc] initWithTextTemplate:@"${barrierNumber}"
        //															   color:[UIColor blackColor]] autorelease];
        //	ts.vAlignment = AGSTextSymbolVAlignmentMiddle;
        //	ts.hAlignment = AGSTextSymbolHAlignmentCenter;
        //	ts.fontSize = 20;
        //	ts.fontWeight = AGSTextSymbolFontWeightBold;
        //	[cs addSymbol:ts];
        
        return cs
    }
    
    //
    // create our route symbol
    //
    func routeSymbol() -> AGSCompositeSymbol {
        let cs = AGSCompositeSymbol()
        
        let sls1 = AGSSimpleLineSymbol()
        sls1.color = UIColor.yellowColor()
        sls1.style = .Solid
        sls1.width = 8
        cs.addSymbol(sls1)
        
        let sls2 = AGSSimpleLineSymbol()
        sls2.color = UIColor.blueColor()
        sls2.style = .Solid
        sls2.width = 4
        cs.addSymbol(sls2)
        
        return cs
    }
    
    //
    // represents the current direction
    //
    func currentDirectionSymbol() -> AGSCompositeSymbol {
        let cs = AGSCompositeSymbol()
        
        let sls1 = AGSSimpleLineSymbol()
        sls1.color = UIColor.whiteColor()
        sls1.style = .Solid
        sls1.width = 8
        cs.addSymbol(sls1)
        
        let sls2 = AGSSimpleLineSymbol()
        sls2.color = UIColor.redColor()
        sls2.style = .Dash
        sls2.width = 4
        cs.addSymbol(sls2)
        
        return cs
    }
    
    //
    // reset the sample so we can perform another route
    //
    func reset() {
        // set stop counter back to 0
        self.numStops = 0
        
        // set barrier counter back to 0
        self.numBarriers = 0
        
        // reset direction index
        self.directionIndex = 0
        
        // remove all graphics
        self.graphicsLayer.removeAllGraphics()
        
        // reset directions label
        self.updateDirectionsLabel("Tap on the map to add stops & barriers")
        
        //
        // if the sketch layer was removed/nil'd out, re-add it
        if self.sketchLayer == nil {
            var geometry:AGSGeometry!
            self.sketchLayer = AGSSketchGraphicsLayer(geometry: geometry)
            self.mapView.insertMapLayer(self.sketchLayer, withName:"sketchLayer", atIndex:1)
            self.mapView.touchDelegate = self.sketchLayer
        }
        else {
            // clear the sketch layer and reset it to a point
            self.sketchLayer.clear()
        }
        
        // disable the next/prev direction buttons
        self.nextBtn.enabled = false
        self.prevBtn.enabled = false
    }
    
    func removeStopClicked() {
        if self.selectedGraphic is AGSStopGraphic {
            // we have a stop
            self.numStops--
        }
        else {
            //barrier
            self.numBarriers--
        }
        
        self.graphicsLayer.removeGraphic(self.selectedGraphic)
        self.selectedGraphic = nil
        
        // hide the callout
        self.mapView.callout.hidden = true
    }
    
    //
    // update our banner's text
    //
    func updateDirectionsLabel(newLabel:String) {
        self.directionsLabel.text = newLabel
    }
    
    //MARK: - IBActions
    

    //
    // if our segment control was changed, then the sketch layer geometry needs to
    // be updated to reflect that (point for stops and polygon for barriers)
    //
    @IBAction func stopsBarriersValChanged(sender:UISegmentedControl) {
        
        if self.sketchLayer == nil {
            return
        }
        
        switch (sender.selectedSegmentIndex) {
        case 0:
            self.sketchLayer.clear()
            self.sketchLayer.geometry = AGSMutablePoint(spatialReference: self.mapView.spatialReference)
        case 1:
            self.sketchLayer.clear()
            self.sketchLayer.geometry = AGSMutablePolygon(spatialReference: self.mapView.spatialReference)
        default:
            break
        }
    }
    
    //
    // perform the route task's solve operation
    //
    @IBAction func routeBtnClicked() {
        self.drawRoute(42.724798, fromLong: -84.481462, toLat: 42.7291990138, toLong: -84.4771316579)
        self.nextBtn.enabled = true
        self.prevBtn.enabled = false
        /*
        // update our banner
        self.updateDirectionsLabel("Routing...")
        
        // if we have a sketch layer on the map, remove it
        
        if let sketchLayer = find(self.mapView.mapLayers as [AGSLayer], self.sketchLayer as AGSLayer) {
        self.mapView.removeMapLayerWithName(self.sketchLayer.name)
        self.mapView.touchDelegate = nil
        self.sketchLayer = nil
        
        //also disable the sketch control so that user cannot sketch
        self.sketchModeSegCtrl.selectedSegmentIndex = -1
        for var i = 0; i < self.sketchModeSegCtrl.numberOfSegments; i++ {
        self.sketchModeSegCtrl.setEnabled(false, forSegmentAtIndex:i)
        }
        }
        
        var stops = [AGSStopGraphic]()
        var polygonBarriers = [AGSGraphic]()
        
        // get the stop, barriers for the route task
        for g in self.graphicsLayer.graphics {
            // if it's a stop graphic, add the object to stops
            if g is AGSStopGraphic {
                stops.append(g as AGSStopGraphic)
            }
                
                // if "barrierNumber" exists in the attributes, we know it is a barrier
                // so add the object to our barriers
            else if g.attributeAsStringForKey("barrierNumber") != nil {
                print(g.dynamicType.description())
                polygonBarriers.append(g as AGSGraphic)
            }
            
            
        }
        
        // set the stop and polygon barriers on the parameters object
        if (stops.count > 0) {
            self.routeTaskParams.setStopsWithFeatures(stops)
        }
        
        if (polygonBarriers.count > 0) {
            self.routeTaskParams.setPolygonBarriersWithFeatures(polygonBarriers)
        }
        
        // this generalizes the route graphics that are returned
        self.routeTaskParams.outputGeometryPrecision = 5.0
        self.routeTaskParams.outputGeometryPrecisionUnits = .Meters
        
        // return the graphic representing the entire route, generalized by the previous
        // 2 properties: outputGeometryPrecision and outputGeometryPrecisionUnits
        self.routeTaskParams.returnRouteGraphics = true
        
        // this returns turn-by-turn directions
        self.routeTaskParams.returnDirections = true
        
        // the next 3 lines will cause the task to find the
        // best route regardless of the stop input order
        self.routeTaskParams.findBestSequence = true
        self.routeTaskParams.preserveFirstStop = true
        self.routeTaskParams.preserveLastStop = false
        
        // since we used "findBestSequence" we need to
        // get the newly reordered stops
        self.routeTaskParams.returnStopGraphics = true
        
        // ensure the graphics are returned in our map's spatial reference
        self.routeTaskParams.outSpatialReference = self.mapView.spatialReference;
        
        // let's ignore invalid locations
        self.routeTaskParams.ignoreInvalidLocations = true
        
        // you can also set additional properties here that should
        // be considered during analysis.
        // See the conceptual help for Routing task.
        
        // execute the route task
        self.routeTask.solveWithParameters(self.routeTaskParams)
*/
    }
    
    func drawRoute(fromLat: Double, fromLong: Double, toLat: Double, toLong: Double) {
        
        // update our banner
        self.updateDirectionsLabel("Routing...")
        
        // if we have a sketch layer on the map, remove it
        /*
        if let sketchLayer = find(self.mapView.mapLayers as [AGSLayer], self.sketchLayer as AGSLayer) {
        self.mapView.removeMapLayerWithName(self.sketchLayer.name)
        self.mapView.touchDelegate = nil
        self.sketchLayer = nil
        
        //also disable the sketch control so that user cannot sketch
        self.sketchModeSegCtrl.selectedSegmentIndex = -1
        for var i = 0; i < self.sketchModeSegCtrl.numberOfSegments; i++ {
        self.sketchModeSegCtrl.setEnabled(false, forSegmentAtIndex:i)
        }
        }*/
        
        var stops = [AGSStopGraphic]()
        var fromPoint = AGSPoint(x: fromLong, y: fromLat, spatialReference: AGSSpatialReference(WKID: 4326))
        var toPoint = AGSPoint(x: toLong, y: toLat, spatialReference: AGSSpatialReference(WKID: 4326))
        
        stops.append(AGSStopGraphic(geometry: fromPoint, symbol: nil, attributes: nil))
        stops.append(AGSStopGraphic(geometry: toPoint, symbol: nil, attributes: nil))
        self.routeTaskParams.setStopsWithFeatures(stops)
        
        // this generalizes the route graphics that are returned
        self.routeTaskParams.outputGeometryPrecision = 5.0
        self.routeTaskParams.outputGeometryPrecisionUnits = .Meters
        
        // return the graphic representing the entire route, generalized by the previous
        // 2 properties: outputGeometryPrecision and outputGeometryPrecisionUnits
        self.routeTaskParams.returnRouteGraphics = true
        
        // this returns turn-by-turn directions
        self.routeTaskParams.returnDirections = true
        
        // the next 3 lines will cause the task to find the
        // best route regardless of the stop input order
        self.routeTaskParams.findBestSequence = true
        self.routeTaskParams.preserveFirstStop = true
        self.routeTaskParams.preserveLastStop = false
        
        // since we used "findBestSequence" we need to
        // get the newly reordered stops
        self.routeTaskParams.returnStopGraphics = true
        
        // ensure the graphics are returned in our map's spatial reference
        self.routeTaskParams.outSpatialReference = self.mapView.spatialReference;
        
        // let's ignore invalid locations
        self.routeTaskParams.ignoreInvalidLocations = true
        
        // you can also set additional properties here that should
        // be considered during analysis.
        // See the conceptual help for Routing task.
        
        // execute the route task
        self.routeTask.solveWithParameters(self.routeTaskParams)
        
        self.mapView.locationDisplay.autoPanMode = .Navigation

    }
    
    func drawRouteFromCurrentLocationToBuilding(toBuilding: Building) {
        self.updateDirectionsLabel("Getting your location ...")
        
        //Start the map's gps if it isn't enabled already
        if !self.mapView.locationDisplay.dataSourceStarted {
            self.mapView.locationDisplay.startDataSource()
        }
        
        destinationBuilding = toBuilding
        routingFlag = true
    }

    
    //
    // clear the sketch layer
    //
    @IBAction func clearSketchLayer() {
        self.sketchLayer.clear()
    }
    
    //
    // move to the next direction in the direction set
    //
    @IBAction func nextBtnClicked() {
        self.directionIndex++
        
        // remove current direction graphic, so we can display next one
        if self.currentDirectionGraphic != nil {
            if let graphic = find(self.graphicsLayer.graphics as [AGSGraphic], self.currentDirectionGraphic as AGSGraphic) {
                self.graphicsLayer.removeGraphic(self.currentDirectionGraphic)
            }
        }
        
        // get current direction and add it to the graphics layer
        let directions = self.routeResult.directions
        self.currentDirectionGraphic = directions.graphics[self.directionIndex] as AGSDirectionGraphic
        self.currentDirectionGraphic.symbol = self.currentDirectionSymbol()
        self.graphicsLayer.addGraphic(self.currentDirectionGraphic)
        
        // update banner
        self.updateDirectionsLabel(self.currentDirectionGraphic.text)
        
        // zoom to envelope of the current direction (expanded by factor of 1.3)
        let env = self.currentDirectionGraphic.geometry.envelope.mutableCopy() as AGSMutableEnvelope
        env.expandByFactor(1.3)
        self.mapView.zoomToEnvelope(env, animated:true)
        
        // determine if we need to disable a next/prev button
        if self.directionIndex >= self.routeResult.directions.graphics.count - 1 {
            self.nextBtn.enabled = false
        }
        if self.directionIndex > 0 {
            self.prevBtn.enabled = true
        }
    }
    
    @IBAction func prevBtnClicked() {
        self.directionIndex--;
        
        // remove current direction
        if self.currentDirectionGraphic != nil {
            if let graphic = find(self.graphicsLayer.graphics as [AGSGraphic], self.currentDirectionGraphic as AGSGraphic) {
                self.graphicsLayer.removeGraphic(self.currentDirectionGraphic)
            }
        }
        
        // get next direction
        let directions = self.routeResult.directions
        self.currentDirectionGraphic = directions.graphics[self.directionIndex] as AGSDirectionGraphic
        self.currentDirectionGraphic.symbol = self.currentDirectionSymbol()
        self.graphicsLayer.addGraphic(self.currentDirectionGraphic)
        
        // update banner text
        self.updateDirectionsLabel(self.currentDirectionGraphic.text)
        
        // zoom to env factored by 1.3
        let env = self.currentDirectionGraphic.geometry.envelope.mutableCopy() as AGSMutableEnvelope
        env.expandByFactor(1.3)
        self.mapView.zoomToEnvelope(env, animated:true)
        
        // determine if we need to disable next/prev button
        if self.directionIndex <= 0 {
            self.prevBtn.enabled = false
        }
        if self.directionIndex < self.routeResult.directions.graphics.count - 1 {
            self.nextBtn.enabled = true
        }
    }
    
    //MARK: - AGSLayerCalloutDelegate
    
    func callout(callout: AGSCallout!, willShowForFeature feature: AGSFeature!, layer: AGSLayer!, mapPoint: AGSPoint!) -> Bool {
        let graphic = feature as AGSGraphic
        
        let stopNum = graphic.attributeAsStringForKey("stopNumber")
        let barrierNum = graphic.attributeAsStringForKey("barrierNumber")
        
        if stopNum != nil || barrierNum != nil {
            self.selectedGraphic = graphic
            self.mapView.callout.customView = self.stopCalloutView
            self.sketchLayer.clear()
            return true
        }else{
            return false
        }
    }
    
    // - GPS delegate
    
    override func observeValueForKeyPath(keyPath: (String!), ofObject object: (AnyObject!), change: ([NSObject : AnyObject]!), context: UnsafeMutablePointer<Void>) {
        if (keyPath == "location" && routingFlag) {
            readyToRoute()
        }
        
        else if (keyPath == "mapAnchor") {
            NSLog("map center changed")
        }
    }
    
    // Wait for both getting user location and getting default routeTaskParams to complete
    func readyToRoute() {
        if self.mapView.locationDisplay.location == nil || self.routeTaskParams == nil || !self.routingFlag {
            return
        } else {
            routingFlag = false
            if destinationBuilding != nil {
                var currentLocation = self.mapView.locationDisplay.location
                drawRoute(currentLocation.point.y, fromLong: currentLocation.point.x, toLat: destinationBuilding.latitude.doubleValue, toLong: destinationBuilding.longitude.doubleValue)
            } else {
                NSLog("Destination building is nil")
            }
        }
    }
}
