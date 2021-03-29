//
//  SwiftUIView.swift
//  GH-Users
//
//  Created by Vidhyadharan on 28/03/21.
//

import SwiftUI

struct SwiftViewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let appDIContainer = AppDIContainer()
        
        let navigationController = UINavigationController()

        let appCoordinator = AppCoordinator(navigationController: navigationController, appDIContainer: appDIContainer)
        appCoordinator.start()
            
        return navigationController.view
    }
    
    func updateUIView(_ view: UIView, context: Context) {
        
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SwiftViewRepresentable().preferredColorScheme(.light).edgesIgnoringSafeArea(.all)
            SwiftViewRepresentable().preferredColorScheme(.dark).edgesIgnoringSafeArea(.all)

        }
    }
}
