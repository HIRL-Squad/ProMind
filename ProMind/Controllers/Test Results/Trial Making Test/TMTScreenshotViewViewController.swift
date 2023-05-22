//
//  TMTScreenshotViewViewController.swift
//  ProMind
//
//  Created by HAIKUO YU on 1/5/23.
//

import UIKit

class TMTScreenshotViewViewController: UINavigationController {
    public var masterCell: TMTTestResultTableViewCells?
    public var indexPath: IndexPath = IndexPath()
    
    private let tmtRecordCoreDataModel = TMTRecordCoreDataModel.shared
    private let localFileIO = LocalFileIO()
    
    @IBOutlet var screenshotImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View did load for TMTScreenshotViewViewController!")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("View will appear for TMTScreenshotViewViewController!")
        tmtRecordCoreDataModel.fetchRecords()
        
        screenshotImageView = UIImageView(image: try! UIImage(gifName: "avatar_1.gif"))
        print(String(describing: screenshotImageView))
        print("Load Test Images: \(String(describing: fetchScreenshot()))")
    }
    
    private func fetchScreenshot() -> UIImage? {
        if let masterCell {
            let testRecord = tmtRecordCoreDataModel.savedEntities[indexPath.row]
            
            switch masterCell {
            case .testAScreenshotCell:
                let url: URL = testRecord.tmtImagePathTestA!
                if #available(iOS 16.0, *) {
                    print("TMT Image Path Test A: \(url.path())")
                } else {
                    // Fallback on earlier versions
                }
                return localFileIO.loadImageFromURL(url)
                
            case .testBScreenshotCell:
                let url: URL = testRecord.tmtImagePathTestB!
                if #available(iOS 16.0, *) {
                    print("TMT Image Path Test B: \(url.path())")
                } else {
                    // Fallback on earlier versions
                }
                return localFileIO.loadImageFromURL(url)
                
            default:
                print("Incorrect master cell for TMT screenshot view!")
                return nil
            }
        }
        return nil
    }
}
