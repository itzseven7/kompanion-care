//
//  StoryCarouselView.swift
//  KompanionCareTechnicalTest
//
//  Created by Romain Dubreucq on 28/04/2025.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct StoryCarouselView: View {
    let store: StoreOf<StoryCarousel>
    
    @GestureState private var dragOffset: CGSize = .zero

    var body: some View {
        Group {
            if store.loading {
                ProgressView()
                    .progressViewStyle(.circular)
            } else {
                storyCarousel
            }
        }
        .onAppear {
            store.send(.loadStories)
        }
    }
    
    private var storyCarousel: some View {
        ZStack(alignment: .center) {
            if !store.stories.isEmpty {
                store.currentStory.image
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(store.currentStory.color)
                    .padding()
                    .gesture(
                        DragGesture()
                            .updating($dragOffset) { value, state, _ in
                                state = value.translation
                            }
                            .onEnded { value in
                                if value.translation.width < -100 {
                                    store.send(.nextStory)
                                } else if value.translation.width > 100 {
                                    store.send(.previousStory)
                                }
                            }
                    )
                VStack {
                    ProgressView(value: store.timerProgress)
                        .progressViewStyle(.linear)
                    Spacer()
                }
            }
        }
        .padding()
        .animation(.easeInOut, value: store.currentStoryIndex)
    }
}
