//
//  DetailedViewController.swift
//  Yelp
//
//  Created by Jacob Smith on 1/23/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

class DetailedViewController: UIViewController, MKMapViewDelegate {

    var business: Business!
    var image: UIImage!
    @IBOutlet weak var frontimage: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var reviewsCountLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        nameLabel.preferredMaxLayoutWidth = nameLabel.frame.size.width
        
        let centerLocation = CLLocation(latitude: business.latitude!, longitude: business.longitude!)
        goToLocation(location: centerLocation)
        let coordinate = CLLocationCoordinate2D.init(latitude: business.latitude!, longitude: business.longitude!)
        addAnnotationAtCoordinate(coordinate: coordinate)
        
        nameLabel.text = business.name
        categoryLabel.text = business.categories
        reviewsCountLabel.text = "\(business.reviewCount!) Reviews"
        ratingImageView.setImageWith(business.ratingImageURL!)
        distanceLabel.text = business.distance
        
        frontimage.image = image
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.alpha = 0.8
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        frontimage.addSubview(blurEffectView)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func goToLocation(location: CLLocation) {
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegionMake(location.coordinate, span)
        mapView.setRegion(region, animated: false)
    }

    func addAnnotationAtCoordinate(coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = business.address!
        mapView.addAnnotation(annotation)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
