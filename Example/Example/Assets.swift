//
//  Assets.swift
//  Example
//
//  Created by yoshida hiroyuki on 2017/02/27.
//  Copyright © 2017年 hiroyuki yoshida. All rights reserved.
//

import UIKit

struct Assets {
    static let image = Assets.Image.share
    struct Image {
        static let share: Assets.Image = Image()
        var sample1: UIImage {
            return UIImage(named: "sample1")!
        }
        var sample2: UIImage {
            return UIImage(named: "sample2")!
        }
    }
}
