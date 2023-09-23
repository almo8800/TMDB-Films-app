//
//  UIImageView+Gradient.swift
//  pet-TMDB-app
//
//  Created by Alexey Mokrousov on 22/9/23.
//

import UIKit

extension UIView{
  
   func addBlackGradientLayerInBackground(colors:[UIColor]){
    let gradient = CAGradientLayer()
    gradient.frame = self.frame
    gradient.colors = colors.map{$0.cgColor}
       self.layer.insertSublayer(gradient, at: 0)
   }
}
