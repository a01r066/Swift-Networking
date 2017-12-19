//
//  GCD.swift
//  Swift_Networking
//
//  Created by Thanh Minh on 12/19/17.
//  Copyright © 2017 IMT Solutions. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ update: @escaping () -> Void){
    DispatchQueue.main.async {
        update()
    }
}
