//
//  TagListExample.swift
//
//
//  Created by Oleh Korchytskyi on 12.01.2024.
//

import SwiftUI
import Fit


struct Tag: Identifiable {
    let id = UUID()
    let name: String
}

struct TagListExample: View {
    
    @State private var tags: [Tag] = [
        Tag(name: "Swift"),
        Tag(name: "SwiftUI"),
        Tag(name: "Observable"),
        Tag(name: "UIKit"),
        Tag(name: "URLSession"),
        Tag(name: "Swift Concurrency"),
        Tag(name: "SwiftData"),
        Tag(name: "Fit"),
    ]
    
    @State private var input: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Fit(lineSpacing: 12, itemAlignment: .firstTextBaseline) {
                
                Text("Tags:")
                
                ForEach(tags) { tag in
                    TagView(tag: tag) {
                        tags.removeAll { $0.id == tag.id }
                    }
                }
                
                TextField("New tag", text: $input)
                    .textFieldStyle(.plain)
                    .onSubmit {
                        guard input.isEmpty == false else { return }
                        
                        tags.append(Tag(name: input))
                        input = ""
                    }
                    .frame(maxWidth: 100)
                    .padding(.horizontal, 10)
                    .background {
                        Capsule()
                            .fill(.gray.opacity(0.2))
                            .padding(.vertical, -4)
                    }
            }
            
            .animation(.easeInOut(duration: 0.27), value: tags.count)
            
            Spacer()
        }
        .frame(width: 420, height: 180, alignment: .leading)
        .padding()
    }
}

struct TagView: View {
    
    let tag: Tag
    
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Text(tag.name)
            Button {
                onDelete()
            } label: {
                Image(systemName: "x.circle.fill")
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
        .background {
            Capsule()
                .fill(.gray.opacity(0.2))
                .padding(.vertical, -4)
        }
        .transition(.scale.combined(with: .opacity))
    }
}

#Preview {
    TagListExample()
}
