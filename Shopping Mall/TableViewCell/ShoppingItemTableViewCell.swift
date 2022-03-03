//
//  ShoppingItemTableViewCell.swift
//  Shopping Mall
//
//  Created by Jarukorn Thuengjitvilas on 1/3/2565 BE.
//

import UIKit
import AlamofireImage

class ShoppingItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    override func prepareForReuse() {
        self.itemImageView.image = nil
    }
    
    public func set(shoppingItemResponse: ShoppingItemResponse) {
        // Load image from URL (Native with out Cache)
//        if let url: URL = URL(string: shoppingItemResponse.imageUrl) {
//            DispatchQueue.global().async { [weak self] in
//                if let data = try? Data(contentsOf: url) {
//                    if let image = UIImage(data: data) {
//                        DispatchQueue.main.async {
//                            self?.itemImageView.image = image
//                        }
//                    }
//                }
//            }
//        }
        
        if let url = URL(string: shoppingItemResponse.imageUrl) {
            self.itemImageView.af.setImage(withURL: url, cacheKey: shoppingItemResponse.imageUrl, completion: nil)
        }
        
        self.itemTitleLabel.text = shoppingItemResponse.title
        self.costLabel.text = "฿ \(shoppingItemResponse.cost)"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
