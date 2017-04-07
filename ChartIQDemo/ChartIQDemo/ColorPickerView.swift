//
//  ColorPickerView.swift
//  ChartIQDemo
//
//  Created by Tao Man Kit on 9/2/2017.
//  Copyright © 2017 ROKO. All rights reserved.
//

import UIKit

class ColorPickerView: UIView {

    // MARK: - Properties
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var collectionViewTop: NSLayoutConstraint!
    var colors = UIColor.colorsForColorPicker()
    var colorDidChangeBlock: ((UIColor) -> Void)?
    var direction = Direction.top {
        didSet {
            collectionViewTop.constant = direction.top
            bgImageView.image = direction.image
        }
    }
    
    enum Direction: Int {
        case top
        case bottom
        
        var top: CGFloat {
            switch self {
            case .top:
                return 5
            default:
                return 15
            }
        }
        
        var image: UIImage {
            switch self {
            case .top: return #imageLiteral(resourceName: "StudyColorPickerBgTop")
            case .bottom: return #imageLiteral(resourceName: "StudyColorPickerBgBottom")
            }
        }
    }

    // MARK: - View Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.register(UINib(nibName: "ColorCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ColorCollectionViewCell")
    }
    
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout

extension ColorPickerView : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCollectionViewCell", for: indexPath)
        cell.backgroundColor = colors[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        colorDidChangeBlock?(colors[indexPath.row])
    }
}
