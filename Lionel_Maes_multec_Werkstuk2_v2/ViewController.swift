//
//  ViewController.swift
//  Lionel_Maes_multec_Werkstuk2_v2
//
//  Created by MAES Lionel (s) on 04/05/2018.
//  Copyright © 2018 MAES Lionel (s). All rights reserved.
//

import UIKit
import CoreData
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var map: MKMapView!
    
    
    let managedContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
        var opgehaaldeStations:[VilloStation]
        
        
        
       
      
        
        //ophalen json
        
        let url = URL(string: "https://api.jcdecaux.com/vls/v1/stations?apiKey=6d5071ed0d0b3b68462ad73df43fd9e5479b03d6&contract=Bruxelles-Capitale")
         let urlRequest = URLRequest(url: url!)
        let urlSession = URLSession(configuration:URLSessionConfiguration.default)
        let task = urlSession.dataTask(with: urlRequest){
            (data, response, error) in
                        print("tekst")
            guard error == nil else {
                print("error calling get")
                print(error!)
                return
            }
            guard let responseData = data else{
                print("error recieving data")
                return
            }
            do {
              guard let villoData = try? JSONSerialization.jsonObject(with: responseData, options: []) as? [AnyObject]
                else{
                    print("failed jsonSerialization")
                    return
                }
                
                for villo in villoData!{
                    let naam = villo["name"] as! String
                    let bikeStands = villo["bike_stands"] as! Int
                    let availableBikeStands = villo["available_bike_stands"] as! Int
                    let availableBikes = villo["available_bikes"] as! Int
                    
                    let pos = villo["position"] as? [String: Double]
                    let latitude = pos!["lat"]
                    let longitude = pos!["lng"]
                 
                    //coreData
                    
                    let station = NSEntityDescription.insertNewObject(forEntityName: "VilloStation", into: self.managedContext!) as! VilloStation
                    
                /*    station.naam = naam
                    station.hoeveelSlotsBeschikbaar = Int16(availableBikeStands)
                    station.hoeveelFietsenBeschikbaar = Int16(availableBikes)
                    station.lat = latitude!
                    station.lon = longitude!
                    station.hoeveelSlotsTotaal = Int16(bikeStands)*/
                    
                    station.setValue(naam, forKey: "naam")
                    station.setValue(availableBikeStands, forKey: "hoeveelSlotsBeschikbaar")
                    station.setValue(availableBikes, forKey: "hoeveelFietsenBeschikbaar")
                    station.setValue(latitude, forKey: "lat")
                    station.setValue(longitude, forKey: "lon")
                    station.setValue(bikeStands, forKey: "hoeveelSlotsTotaal")
                    
                    do{
                        try self.managedContext?.save()
                    }catch{
                        fatalError("fail to save in core \(error)")
                    }
                }
                DispatchQueue.main.async {
                    // ---
                }
            }catch{
                return
            }
        }
        
        let stationFetch = NSFetchRequest<NSFetchRequestResult>(entityName : "VilloStation")
        
        do{ opgehaaldeStations = try managedContext?.fetch(stationFetch) as! [VilloStation]
            
            for station in opgehaaldeStations{
                print(station.naam!)
              
            }
            
        }catch{
            fatalError("failed find stations \(error)")
        }
        
        //map tonen
        let lat = 50.862437
        let lon = 4.312991
        
        let span = MKCoordinateSpanMake(0.5, 0.5)
        let location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let region = MKCoordinateRegionMake(location, span)
        map.setRegion(region, animated: true)
        
        //annotations toevoegen
        for station in opgehaaldeStations
        {
            let annotation = MKPointAnnotation()
            
            let positieStation = CLLocationCoordinate2DMake(station.lat, station.lon)
            
            annotation.coordinate = positieStation
            annotation.title = station.naam!
            annotation.subtitle = "totaal aantal slots"
            map.addAnnotation(annotation)
            print(station.naam!)
            print("some")
        }
        
 
        

        task.resume()
    }

    func delete() {
        let something = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        let delete = NSBatchDeleteRequest(fetchRequest: VilloStation.fetchRequest())
        
        do{
            try something?.execute(delete)
        }
        catch{
            
        }
    }
    
    func ophalen() {
        <#function body#>
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

