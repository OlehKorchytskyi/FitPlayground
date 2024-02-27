//
//  LongTextExample.swift
//  FitPlayground
//
//  Created by Oleh Korchytskyi on 22.01.2024.
//

import SwiftUI
import Fit


struct TextItem: Identifiable {
    let id: Int
    let value: LocalizedStringKey
}

struct LongTextExample: View {
    
    let words: [TextItem]
    
    @State private var stretch: Bool = true
    @State private var threshold: Double = 0.8
    
    private var lineStyle: LineStyle {
        .lineSpecific { style, line in
            if stretch {
                style.stretched = line.percentageFilled >= threshold
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .trailing) {
            ScrollView {
                Fit(lineStyle: lineStyle) {
                    ForEach(words) { word in
                        Text(word.value)
                    }
                }
                .font(.system(size: 16))
                .padding(.vertical)
                .alignmentGuide(.horizontalThreshold) { d in
                    d[.trailing] * threshold
                }
                .overlay(alignment: .horizontalThreshold) {
                    if stretch {
                        thresholdLine
                            .alignmentGuide(.horizontalThreshold) { d in
                                d[HorizontalAlignment.center]
                            }
                    }
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(.bar, in: .rect(cornerRadius: 8))

            HStack {
                Toggle("Stretch", isOn: $stretch)
                Spacer()
                Slider(value: $threshold) {
                    Text("Threshold")
                }
                .disabled(!stretch)
                .frame(width: 240)
            }
            .padding(.leading, 4)
            
        }
        .padding()
        .frame(maxWidth: 420, maxHeight: 280, alignment: .leading)
    }
    
    @ViewBuilder
    private var thresholdLine: some View {
        VStack {
            Rectangle()
                .fill(.primary.opacity(0.3))
                .frame(width: 2)
            Text(threshold, format: .percent.precision(.fractionLength(1)))
                .bold()
        }
    }
    
}

extension HorizontalAlignment {
    private struct HorizontalThreshold: AlignmentID {
        static func defaultValue(in d: ViewDimensions) -> CGFloat {
            d[.trailing]
        }
    }

    static let horizontalThreshold = HorizontalAlignment(HorizontalThreshold.self)
}

extension Alignment {
    static let horizontalThreshold = Alignment(horizontal: .horizontalThreshold, vertical: .center)
}

#Preview {
    LongTextExample(
        words: "**SwiftUI** helps you build great-looking apps across all **Apple** platforms with the power of **Swift** — and surprisingly little code. You can bring even better experiences to everyone, on any **Apple** device, using just one set of tools and **APIs**."
            .components(separatedBy: .whitespacesAndNewlines)
            .reduce(into: []) { result, element in
                result.append(TextItem(id: result.count, value: LocalizedStringKey(stringLiteral: element)))
            }
    )
}
