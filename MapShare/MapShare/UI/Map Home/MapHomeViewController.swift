//
//  MapHomeViewController.swift
//  MapShare
//
//  Created by iMac Pro on 4/25/23.
//

import MapKit

class MapHomeViewController: UIViewController {

    //MARK: - OUTLETS
    @IBOutlet weak var mapView: MKMapView!
    
    
    //MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupModalHomeSheetController()
    }

    
    //MARK: - FUNCTIONS
    func setupModalHomeSheetController() {
        let storyboard = UIStoryboard(name: "ModalHome", bundle: nil)
        guard let sheetController = storyboard.instantiateViewController(withIdentifier: "ModalHomeVC") as? ModalHomeViewController else { return }
        sheetController.isModalInPresentation = true
        self.parent?.present(sheetController, animated: true, completion: nil)
    }
    
} //: CLASS

