//
//  StoryCarousel.swift
//  KompanionCareTechnicalTest
//
//  Created by Romain Dubreucq on 28/04/2025.
//

import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
struct StoryCarousel {
    
    let storyRepository: StoryRepository
    let timerTick: Float = 0.1
    let storyDuration: Float = 2.0
    
    private let timerIdentifier = "TimerID"
    
    @ObservableState
    struct State {
        var currentStoryIndex: Int = 0
        var stories: [Story] = []
        var loading: Bool = false
        var errorMessage: String?
        
        fileprivate var elapsedTime: Float = 0
        var timerProgress: Float = 0
        
        fileprivate var timerIsRunning = false
        
        var currentStory: Story {
            stories[currentStoryIndex]
        }
    }
    
    indirect enum Action {
        case loadStories
        case loadedStories([Story])
        case loading
        case stopLoading(Action)
        case setErrorMessage(String)
        
        case nextStory
        case previousStory
        
        case startTimer
        case createTimer
        case timerUpdate
        case stopTimer
        case enableTimer(Bool)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .loadStories:
                return .run { send in
                    await send(.loading)
                    let stories = await storyRepository.stories()
                    
                    await send(
                        .stopLoading(
                            .loadedStories(stories)
                        )
                    )
                }
            case .loadedStories(let stories):
                state.stories = stories
                return .send(.startTimer)
            case .loading:
                state.errorMessage = nil
                state.loading = true
                return .none
            case .stopLoading(let nextAction):
                state.errorMessage = nil
                state.loading = false
                return .send(nextAction)
            case .setErrorMessage(let message):
                state.errorMessage = message
                return .none
            case .nextStory:
                guard state.currentStoryIndex + 1 < state.stories.count else {
                    return .send(.stopTimer)
                }
                
                state.currentStoryIndex += 1
                state.elapsedTime = 0
                state.timerProgress = 0
                
                return .none
            case .previousStory:
                guard state.currentStoryIndex - 1 >= 0 else {
                    return .none
                }
                
                state.currentStoryIndex -= 1
                state.elapsedTime = 0
                state.timerProgress = 0
                
                return .none
            case .startTimer:
                return .send(.enableTimer(true))
            case .createTimer:
                let clock = ContinuousClock()
                return .run { send in
                    while !Task.isCancelled {
                        do{
                            try await clock.sleep(for: .seconds(Double(timerTick)))
                            await send(.timerUpdate)
                        }
                        catch{
                            if !Task.isCancelled {
                                assertionFailure("Serious issue here")
                            }
                        }
                    }
                }
                .cancellable(id: timerIdentifier, cancelInFlight: true)
            case .timerUpdate:
                let elapsedTime = state.elapsedTime + timerTick
                
                if elapsedTime >= storyDuration {
                    state.elapsedTime = 0
                    state.timerProgress = 0
                    return .send(.nextStory)
                } else {
                    state.elapsedTime = elapsedTime
                    state.timerProgress = elapsedTime / storyDuration
                    return .none
                }
            case .stopTimer:
                return .send(.enableTimer(false))
            case .enableTimer(let enabled):
                state.timerIsRunning = enabled
                
                if state.timerIsRunning {
                    return .run { send in
                        await send(.createTimer)
                    }
                } else {
                    return .cancel(id: timerIdentifier)
                }
            }
        }
    }
}
