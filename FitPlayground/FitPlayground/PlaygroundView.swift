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
    @State private var itemAlignment: VerticalAlignment = .top
    
    @State private var useViewLineSpacing = true
    @State private var lineSpacing: CGFloat = 0
    
    @State private var useViewSpacing = false
    @State private var minimumSpacing: CGFloat = 8
    
    @State private var reverse = false
    @State private var reverseEvenLinesOnly = false
    @State private var stretch = false
    @State private var stretchThreshold: Double = 0
    
    private var lineSpacingRule: LineSpacing {
        if useViewLineSpacing {
            .viewSpacing(minimum: lineSpacing)
        } else {
            .fixed(lineSpacing)
        }
    }
    
    private var itemSpacingRule: ItemSpacing {
        if useViewSpacing {
            .viewSpacing(minimum: minimumSpacing)
        } else {
            .fixed(minimumSpacing)
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
                
                Fit(
                    lineStyle: lineStyle,
                    lineSpacing: lineSpacingRule,
                    itemAlignment: itemAlignment,
                    itemSpacing: itemSpacingRule
                ) {
                    content()
                }
                .border(showBorder ? Color.gray : .clear)
                
                Text("Test line list")
                
                let verticalGuide = VerticalAlignment.bottom
                HStack(alignment: verticalGuide) {
                    Text("HStack")
                        .alignmentGuide(verticalGuide) { d in
                            d[verticalGuide] + 10
                        }
                    Text("Testing")
                        .alignmentGuide(verticalGuide) { d in
                            d[verticalGuide] + 10
                        }
                    Text("Alignment")
                        .alignmentGuide(verticalGuide) { d in
                            d[verticalGuide] + 10
                        }
                    Text("Guid")
                        .alignmentGuide(verticalGuide) { d in
                            d[verticalGuide] + 10
                        }
                }
                .border(Color.black)
                
                Fit {
                    Text("One item test")
                }
                .border(Color.black)
                
                HStack {
                    Text("Zero items test:")
                    Fit {}.border(Color.black)
                }
                
                Fit {
                    let rectangle = Rectangle()
                        .foregroundStyle(.red)
                        .frame(width: 100, height: 30)
                    rectangle
                        .fit(lineBreak: .after)
                    Text("Text")
                    rectangle
                        .fit(lineBreak: .before)
                }
                .border(Color.black)
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
    
    
    private var configurator: some View {
        List {
            previewOptions
            
            alignmentSelection
            
            lineSpacingSelection
            
            itemSpacingSelection
            
            directionSelection
        }
        .listStyle(.sidebar)
        .scrollContentBackground(.hidden)
    }
    
    private var previewOptions: some View {
        Section("Preview") {
            Toggle("Show border", isOn: $showBorder)
        }
    }
    
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
    

    private var lineSpacingSelection: some View {
        Section("LINE spacing") {
            Toggle("Use view spacing", isOn: $useViewLineSpacing.animation(.easeInOut))
            HStack {

                Slider(value: $lineSpacing.animation(.easeInOut), in: -8...16, step: 1) {
                        Text("Minimum")
                }
                
                Text("\(lineSpacing, format: .number.precision(.integerLength(2)))")
                    .monospaced()
            }
        }
    }
    

    private var itemSpacingSelection: some View {
        Section("ITEM spacing") {
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
                    .fit(lineBreak: .after)
                Text("Swift\nConcurrency")
                    .fit(lineBreak: .after)
                
                Group {
                    let guid = VerticalAlignment.top
                    Text("AA")
                        .alignmentGuide(guid) { $0[guid] + 8 }

                    Text("BB")
                        .alignmentGuide(guid) { $0[guid] - 8 }
                    
                    Text("CC")
                    
                    Text("DD")
                        .alignmentGuide(guid) { $0[guid] - 16 }
                        .fit(lineBreak: .after)
                }
                .overlay(alignment: .top) { VStack { Divider() } }
                
                Text("Numbers:")
                    .fit(lineBreak: .after)
                
                ForEach(1..<21) { number in
                    Text(number, format: .number.precision(.integerLength(2)))
                        .monospaced()
                }
                
                Rectangle()
                    .frame(width: 15, height: 15)
                
                Fit {
                    Text("Testing")
                    Text("Embedded")
                    
                    Fit {
                        Text("Fit")
                        Text("Container")
                    }
                }
            }
            .border(Color.black)
//            .background(.black.opacity(0.3),
//                        in: .rect(cornerRadius: 4))
        }
        .preferredColorScheme(.dark)
    }
}
