//
//  ContentView.swift
//  FlatARBall
//
//  Created by Radomyr Sidenko on 16.06.2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ARViewContainer()
            .ignoresSafeArea()
//        ARViewControllerOld()
    }
}

struct ARViewContainer: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ARViewController {
        ARViewController()
    }
    func updateUIViewController(_ uiViewController: ARViewController, context: Context) {}
}
