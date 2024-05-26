//
//  ConveyorBeltExample.swift
//  FitPlayground
//
//  Created by Oleh Korchytskyi on 17.01.2024.
//

import SwiftUI
import Fit


private struct Package: Identifiable {
    let id: Int
}

struct ConveyorBeltExample: View {
    
    @State private var packages: [Package] = []
    
    let lineStyle: LineStyle = .lineSpecific { style, line in
        // reverse every second line
        style.reversed = (line.index + 1).isMultiple(of: 2)
        // if the line is reversed, it should start from the trailing edge
        style.alignment = style.reversed ? .trailing : .leading
    }
    
    var body: some View {
        ScrollView {
            Fit(lineStyle: lineStyle) {
                Button {
                    if packages.isEmpty {
                        reloadPackages()
                    } else {
                        _ = packages.removeFirst()
                    }
                } label: {
                    Image(systemName: packages.isEmpty ? "arrow.clockwise.square.fill" : "trash.square.fill")
                }
                .buttonStyle(.plain)
                
                ForEach(packages) { package in
                    Image(systemName: "\(package.id).square.fill")
                        .transition(.move(edge: .leading).combined(with: .opacity))
                        .geometryGroup()
                }
            }
            .font(.system(size: 27))
            .padding()
            .animation(.bouncy(duration: 0.3), value: packages.count)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: 420, maxHeight: 180, alignment: .leading)
        .task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            reloadPackages()
        }
    }
    
    func reloadPackages() {
        packages = []
        
        Task { @MainActor in
            for i in 1..<30 where Task.isCancelled == false {
                packages.append(Package(id: i))
                try? await Task.sleep(nanoseconds: 100_000_000)
            }
        }
    }
}

#Preview("Conveyor Belt") {
    ConveyorBeltExample()
}
