//
//  PlaygroundView.swift
//
//
//  Created by Oleh Korchytskyi on 10.01.2024.
//

import SwiftUI
import Fit


struct PlaygroundView<Content: View>: View {
    
    @ViewBuilder let content: () -> Content
    
    @State private var showBorder = true
    
    @State private var linesAlignment: LineAlignment = .leading
    @State private var itemAlignment: VerticalAlignment = .center
    
    @State private var useViewSpacing = true
    @State private var minimumSpacing: CGFloat = 0
    
    @State private var reverse = false
    @State private var reverseEvenLinesOnly = false
    @State private var stretch = false
    @State private var stretchThreshold: Double = 0
    
    private var itemSpacingRule: ItemSpacing {
        if useViewSpacing {
            ItemSpacing.viewSpacing(minimum: minimumSpacing)
        } else {
            ItemSpacing.fixed(minimumSpacing)
        }
    }
    
    private var lineStyle: LineStyle {
        .lineSpecific { style, line in
            style.alignment = linesAlignment
            if reverse {
                style.reversed = true
                if reverseEvenLinesOnly {
                    style.reversed = (line.index + 1).isMultiple(of: 2)
                }
            }
            if stretch {
                style.stretched = line.percentageFilled >= stretchThreshold
            }
        }
    }
    
    private var alignmentIndicator: some View {
        Rectangle()
            .frame(width: 8, height: 8)
    }
    
    var body: some View {
        GeometryReader { geometry in
            List {

                Text("First line in the list")
                Fit(lineStyle: lineStyle, itemAlignment: itemAlignment, itemSpacing: itemSpacingRule) {
                    content()
                }
                .border(showBorder ? Color.gray : .clear)
                
                Text("Test line list")
                
                HStack(alignment: itemAlignment) {
                    ForEach(0..<3) {
                        Text("Text \($0)")
                    }
                }
                
                Text("Test line list")
            }
            .padding()
            .frame(maxWidth: geometry.size.width - 300)
            .background(.bar, in: .rect(cornerRadius: 8))
            
            configurator
                .frame(maxWidth: 300)
                .padding(.leading, geometry.size.width - 300)
        }
        .padding()
    }
    
    
    @ViewBuilder
    private var configurator: some View {
        List {
            previewOptions
            
            alignmentSelection
            
            spacingSelection
            
            directionSelection
        }
        .listStyle(.sidebar)
        .scrollContentBackground(.hidden)
    }
    
    @ViewBuilder
    private var previewOptions: some View {
        Section("Preview") {
            Toggle("Show border", isOn: $showBorder)
        }
    }
    
    @ViewBuilder
    private var alignmentSelection: some View {
        Section("Alignment") {
            VStack {
                Picker("Lines", selection: $linesAlignment.animation(.easeInOut)) {
                    ForEach([
                        LineAlignment.leading,
                        .center,
                        .trailing,
                    ]) { alignment in
                        Text(alignment.title).tag(alignment)
                    }
                }
                
                Picker("Items", selection: $itemAlignment.animation(.easeInOut)) {
                    ForEach([
                        VerticalAlignment.top,
                        .center,
                        .bottom,
                        .firstTextBaseline,
                        .lastTextBaseline
                    ]) { alignment in
                        Text(alignment.title).tag(alignment)
                    }
                }
            }
        }
        .pickerStyle(.menu)
    }
    
    @ViewBuilder
    private var spacingSelection: some View {
        Section("Item spacing") {
            Toggle("Use view spacing", isOn: $useViewSpacing.animation(.easeInOut))
            HStack {

                Slider(value: $minimumSpacing.animation(.easeInOut), in: -8...16, step: 1) {
                        Text("Minimum")
                }
                
                Text("\(minimumSpacing, format: .number.precision(.integerLength(2)))")
                    .monospaced()
            }
            
            Toggle("Stretch to fill available space ", isOn: $stretch.animation(.easeInOut))
            Slider(value: $stretchThreshold) {
                Text("Threshold")
            }
            .disabled(!stretch)
        }
    }
    
    @ViewBuilder
    private var directionSelection: some View {
        Section("Line direction") {
            HStack {
                Toggle("Reverse", isOn: $reverse.animation(.easeInOut))
                Toggle("(even rows only)", isOn: $reverseEvenLinesOnly.animation(.easeInOut))
                    .disabled(reverse == false)
            }
        }
    }
    
    private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
}

extension LineAlignment: Identifiable {
    
    public var id: String { title }
    
    public var title: String {
        switch self {
        case .leading:
            ".leading"
        case .center:
            ".center"
        case .trailing:
            ".trailing"
        }
    }
    
}

extension VerticalAlignment: Hashable, Identifiable {
    
    public var id: String { title }

    public var title: String {
        switch self {
        case .top:
            ".top"
        case .center:
            ".center"
        case .bottom:
            ".bottom"
        case .firstTextBaseline:
            ".firstTextBaseline"
        case .lastTextBaseline:
            ".lastTextBaseline"
            
        default:
            "unknown"
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
}


#Preview(traits: .fixedLayout(width: 800, height: 600)) {
    PlaygroundPreview()
}

struct PlaygroundPreview: View {
    
    var body: some View {
        PlaygroundView {
            Group {
                
                Image(systemName: "swift")
                    .imageScale(.large)
                
                Text("Swift")
                Text("SwiftUI")
                Text("Swift\nConcurrency")
                    .fit(lineBreak: .after)
                
                ForEach(1..<21) { number in
                    
                    let view =
                    Text(number, format: .number.precision(.integerLength(2)))
                        .monospaced()
                        .border(Color.yellow)
                    
                    if number == 5 {
                        view
                            .alignmentGuide(VerticalAlignment.center) { dimension in
                                dimension[VerticalAlignment.center] - 20
                            }
                    } else {
                        view
                    }
                    
                }
                
                Fit {
                    Text("Test")
                    Text("Test")
                    Fit {
                        Text("Test")
                        Text("Test")
                        Text("Test")
                    }
                }
                
            }
            .padding(6)
            .background(.black, in: .rect(cornerRadius: 4))
        }
        .preferredColorScheme(.dark)

    }
}
