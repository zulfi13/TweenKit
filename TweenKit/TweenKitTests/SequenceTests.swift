//
//  SequenceTests.swift
//  TweenKit
//
//  Created by Steven Barnegren on 20/03/2017.
//  Copyright © 2017 Steve Barnegren. All rights reserved.
//

import XCTest
@testable import TweenKit

class SequenceTests: XCTestCase {
   
    var scheduler: Scheduler!
    
    override func setUp() {
        super.setUp()
        scheduler = Scheduler()
    }
    
    func testDurationIsSumOfActionsDuration() {
        
        let action1 = InterpolationAction(from: 0.0, to: 1.0, duration: 1.0, update: {_ in})
        let action2 = InterpolationAction(from: 0.0, to: 1.0, duration: 2.0, update: {_ in})
        let action3 = InterpolationAction(from: 0.0, to: 1.0, duration: 3.0, update: {_ in})
        let sequence = Sequence(actions: action1, action2, action3)
        
        let expectedDuration = action1.duration + action2.duration + action3.duration
        
        XCTAssertEqualWithAccuracy(sequence.duration, expectedDuration, accuracy: 0.001)
    }
    
    func testActionsEventsAreCalledInExpectedOrder() {
        
        func makeBecomeActiveString(tag: Int) -> String { return "Become Active: \(tag)" }
        func makeBecomeInactiveString(tag: Int) -> String { return "Become Inactive: \(tag)" }
        func makeWillBeginString(tag: Int) -> String { return "Will Begin: \(tag)" }
        func makeDidFinishString(tag: Int) -> String { return "Did Finish: \(tag)" }

        var events = [String]()
        
        func makeAction(tag: Int) -> FiniteTimeActionTester {
            let action = FiniteTimeActionTester(duration: 0.1)
            action.onBecomeActive = { events.append(makeBecomeActiveString(tag: tag)) }
            action.onBecomeInactive = { events.append(makeBecomeInactiveString(tag: tag)) }
            action.onWillBegin = { events.append(makeWillBeginString(tag: tag)) }
            action.onDidFinish = { events.append(makeDidFinishString(tag: tag)) }
            return action
        }
        
        let action1 = makeAction(tag: 1)
        let action2 = makeAction(tag: 2)
        let action3 = makeAction(tag: 3)
        
        let sequence = Sequence(actions: action1, action2, action3)
        let animation = Animation(action: sequence)
        scheduler.add(animation: animation)
        scheduler.progressTime(duration: sequence.duration + 0.1)
        
        let expectedEvents: [String] = [makeBecomeActiveString(tag: 1),
                                        makeWillBeginString(tag: 1),
                                        makeDidFinishString(tag: 1),
                                        makeBecomeInactiveString(tag: 1),
                                        makeBecomeActiveString(tag: 2),
                                        makeWillBeginString(tag: 2),
                                        makeDidFinishString(tag: 2),
                                        makeBecomeInactiveString(tag: 2),
                                        makeBecomeActiveString(tag: 3),
                                        makeWillBeginString(tag: 3),
                                        makeDidFinishString(tag: 3),
                                        makeBecomeInactiveString(tag: 3),
                                        ]
        
        XCTAssertEqual(events, expectedEvents)
    }
    
    func testActionsEventsAreCalledInExpectedOrderWhenInReverseAction() {
        
        let eventLog = EventLog()
        
        let action1 = FiniteTimeActionTester(duration: 0.1, externalEventLog: eventLog, tag: 1)
        let action2 = FiniteTimeActionTester(duration: 0.2, externalEventLog: eventLog, tag: 2)
        let action3 = FiniteTimeActionTester(duration: 0.3, externalEventLog: eventLog, tag: 3)
        
        let sequence = Sequence(actions: action1, action2, action3)
        sequence.simulateFullLifeCycle()

        let expectedEvents: [EventType] = [.willBecomeActiveWithTag(1),
                                           .willBeginWithTag(1),
                                           .didFinishWithTag(1),
                                           .didBecomeInactiveWithTag(1),
                                           .willBecomeActiveWithTag(2),
                                           .willBeginWithTag(2),
                                           .didFinishWithTag(2),
                                           .didBecomeInactiveWithTag(2),
                                           .willBecomeActiveWithTag(3),
                                           .willBeginWithTag(3),
                                           .didFinishWithTag(3),
                                           .didBecomeInactiveWithTag(3),
                                           ]
        
        AssertLifeCycleEventsAreAsExpected(recordedEvents: eventLog.events,
                                           expectedEvents: expectedEvents,
                                           filter: .onlyMatchingExpectedEventsTypes)
    }

    /*
    func testActionsEventsAreCalledInExpectedOrderWhenInReverseAction() {
        
        func makeBecomeActiveString(tag: Int) -> String { return "Become Active: \(tag)" }
        func makeBecomeInactiveString(tag: Int) -> String { return "Become Inactive: \(tag)" }
        func makeWillBeginString(tag: Int) -> String { return "Will Begin: \(tag)" }
        func makeDidFinishString(tag: Int) -> String { return "Did Finish: \(tag)" }
        
        var events = [String]()
        
        func makeAction(tag: Int) -> FiniteTimeActionTester {
            let action = FiniteTimeActionTester(duration: 0.1)
            action.onBecomeActive = { events.append(makeBecomeActiveString(tag: tag)) }
            action.onBecomeInactive = { events.append(makeBecomeInactiveString(tag: tag)) }
            action.onWillBegin = { events.append(makeWillBeginString(tag: tag)) }
            action.onDidFinish = { events.append(makeDidFinishString(tag: tag)) }
            return action
        }
        
        let action1 = makeAction(tag: 1)
        let action2 = makeAction(tag: 2)
        let action3 = makeAction(tag: 3)
        
        let reversedSequence = Sequence(actions: action1, action2, action3).reversed()
        let animation = Animation(action: reversedSequence)
        scheduler.add(animation: animation)
        scheduler.progressTime(duration: reversedSequence.duration + 0.1)
        
        let expectedEvents: [String] = [makeBecomeActiveString(tag: 3),
                                        makeWillBeginString(tag: 3),
                                        makeDidFinishString(tag: 3),
                                        makeBecomeInactiveString(tag: 3),
                                        makeBecomeActiveString(tag: 2),
                                        makeWillBeginString(tag: 2),
                                        makeDidFinishString(tag: 2),
                                        makeBecomeInactiveString(tag: 2),
                                        makeBecomeActiveString(tag: 1),
                                        makeWillBeginString(tag: 1),
                                        makeDidFinishString(tag: 1),
                                        makeBecomeInactiveString(tag: 1),
                                        ]
        
        XCTAssertEqual(events, expectedEvents)
    }
 */
    
    func testAllActionsEndInCompletedStates() {
    
        var value1 = 0.0, value2 = 0.0, value3 = 0.0
        
        let action1 = InterpolationAction(from: 0.0, to: 1.0, duration: 0.1, update: { value1 = $0 })
        let action2 = InterpolationAction(from: 0.0, to: 1.0, duration: 0.2, update: { value2 = $0 })
        let action3 = InterpolationAction(from: 0.0, to: 1.0, duration: 0.3, update: { value3 = $0 })

        let sequence = Sequence(actions: action1, action2, action3)
        let animation = Animation(action: sequence)
        scheduler.add(animation: animation)
        scheduler.progressTime(duration: sequence.duration + 0.1, stepSize: 0.05)
        
        XCTAssertEqualWithAccuracy(value1, 1.0, accuracy: 0.001)
        XCTAssertEqualWithAccuracy(value2, 1.0, accuracy: 0.001)
        XCTAssertEqualWithAccuracy(value3, 1.0, accuracy: 0.001)
    }
    
    func testSequenceFullLifeCycleUpdatesInnerActions() {
        
        var value1 = 0.0, value2 = 0.0, value3 = 0.0
        
        let action1 = InterpolationAction(from: 0.0, to: 1.0, duration: 3.0, update: { value1 = $0 })
        let action2 = InterpolationAction(from: 0.0, to: 1.0, duration: 4.0, update: { value2 = $0 })
        let action3 = InterpolationAction(from: 0.0, to: 1.0, duration: 5.0, update: { value3 = $0 })
        
        let sequence = Sequence(actions: action1, action2, action3)
        sequence.simulateFullLifeCycle()
        
        XCTAssertEqualWithAccuracy(value1, 1.0, accuracy: 0.001)
        XCTAssertEqualWithAccuracy(value2, 1.0, accuracy: 0.001)
        XCTAssertEqualWithAccuracy(value3, 1.0, accuracy: 0.001)
    }
    
    func testSequenceFullLifeCycleUpdatesInnerActionsWhenReversed() {
        
        var value1 = 0.0, value2 = 0.0, value3 = 0.0
        
        let action1 = InterpolationAction(from: 0.0, to: 1.0, duration: 3.0, update: { value1 = $0 })
        let action2 = InterpolationAction(from: 0.0, to: 1.0, duration: 4.0, update: { value2 = $0 })
        let action3 = InterpolationAction(from: 0.0, to: 1.0, duration: 5.0, update: { value3 = $0 })
        
        let sequence = Sequence(actions: action1, action2, action3)
        sequence.reverse = true
        sequence.simulateFullLifeCycle()
        
        XCTAssertEqualWithAccuracy(value1, 0.0, accuracy: 0.001)
        XCTAssertEqualWithAccuracy(value2, 0.0, accuracy: 0.001)
        XCTAssertEqualWithAccuracy(value3, 0.0, accuracy: 0.001)
    }
 

    
}
