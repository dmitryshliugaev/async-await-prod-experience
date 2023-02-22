//
//  funWithGroupsTests.swift
//
//
//  Created by Nikolay Dechko on 1/31/23.
//

import XCTest
@testable import TasksDemo

actor StreamScheduler<T> {
    var values: [T] = []

    var continuation: (AsyncStream<T>.Continuation)? = nil

    func next() {
        let value = values.removeFirst()
        continuation?.yield(value)

        if values.isEmpty {
            continuation?.finish()
            continuation = nil
        }
    }

    func setValues(_ values:[T]) {
        self.values = values
    }

    func waitForValues() -> AsyncStream<T> {
        return AsyncStream<T> { continuation in
            self.continuation = continuation
        }
    }
}

extension Task where Success == Never, Failure == Never {
    static func yield(until: @Sendable @escaping () async -> Bool) async {
        while !(await until()) {
            await Task.yield()
        }
    }
}

class ServiceMock: ServiceProtocol {
    var currentProgress: TasksDemo.StepsProgress {
        output.first?.currentProgress ?? .pending
    }

    var output: [(delay: Int, currentProgress: StepsProgress)]

    var testCase: XCTestCase

    var mockExecuteSteps: ((@escaping @Sendable (TasksDemo.StepsProgress) async -> Void) async throws -> Void)?

    @discardableResult
    func mock_executeSteps(scheduler: StreamScheduler<StepsProgress>) -> XCTestExpectation {
        let exp = testCase.expectation(description: "execute steps not called")
        mockExecuteSteps = { progressCallback in
//            Task {
                for await value in await scheduler.waitForValues() {
                    await progressCallback(value)
                }
//            }

            exp.fulfill()
        }

        return exp
    }

    func executeSteps(progressCallBack: @escaping @Sendable (TasksDemo.StepsProgress) async -> Void) async throws {
        if let mockExecuteSteps {
            try await mockExecuteSteps(progressCallBack)
        }
    }


    @discardableResult
    func mock_someAsyncFunction(mock: @escaping (() async throws -> String)) -> XCTestExpectation {
        let exp = testCase.expectation(description: "omeAsyncFunction is not called")

        mockSomeAsyncFunction = {
            defer { exp.fulfill() }
            return try await mock()
        }
        return exp
    }

    var mockSomeAsyncFunction: (() async throws -> String)?
    func someAsyncFunction() async throws -> String {
        if let mockSomeAsyncFunction {
            return try await mockSomeAsyncFunction()
        } else {
            return ""
        }
    }

    init(testCase: XCTestCase) {
        self.output = []
        self.testCase = testCase
    }

}

class ViewControllerMock: ViewControllerProtocol {

    var testCase: XCTestCase

    init(testCase: XCTestCase) {
        self.testCase = testCase
    }

    var mockUpdateUI: ((String) -> ())?

    @discardableResult
    func mock_uppdateUI(mock: @escaping ((String) -> ())) -> XCTestExpectation {
        let exp = testCase.expectation(description: "mockUpdateUI is not called")

        mockUpdateUI = { string in
            mock(string)
            exp.fulfill()
        }
        return exp
    }

    func updateUI(progress: String) {
        if let mockUpdateUI {
            mockUpdateUI(progress)
        }
    }
}

final class funWithGroupsTests: XCTestCase {
    var presenter: Presenter!
    var service: ServiceMock!
    var viewController: ViewControllerMock!

    override func setUpWithError() throws {
        service = ServiceMock(testCase: self)
        viewController = ViewControllerMock(testCase: self)
        presenter = Presenter(service: service, viewController: viewController)
    }

    func testWaitForExpectation() async {
        let exp = expectation(description: "1")
        Task { @MainActor in
            print("main task")
            exp.fulfill()
        }

        // 1: run repeatedly
        await waitForExpectations(timeout: 0.2)

        //2:
//        wait(for: [exp], timeout: 1)
    }

    func testSimpleAsyncUpdate() {
        // expectation is auto-generated with each mock_
        service.mock_someAsyncFunction { "some string" }

        presenter.simpleAsyncUpdate()
        //2:
//        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(presenter.displayedString, "some string")
//        1: run repeatedly
        waitForExpectations(timeout: 0.1)
    }

/// # Out of scope for demo

    func testUsingStreamShort() async {
        let stepsProgress1: StepsProgress = .pending
        let stepsProgress2: StepsProgress = .init(stepOne: .completed, stepTwo: .pending, stepThree: .pending)
        let output: [StepsProgress] = [stepsProgress1,
                                       stepsProgress2]
        let scheduler = StreamScheduler<StepsProgress>()

        await scheduler.setValues(output)

        let exp1 = service.mock_executeSteps(scheduler: scheduler)

        presenter.startSteps()

        for _ in 1...10 {
            await Task.yield()
        }

        do { // Step 1:
            let exp = viewController.mock_uppdateUI { string in
                print(string)
            }

            await scheduler.next()

            wait(for: [exp], timeout: 0.1)
        }

        do  { // Step 2:
            let exp = viewController.mock_uppdateUI { string in
                print(string)
            }
            await scheduler.next()

            wait(for: [exp], timeout:  0.1)
        }

        wait(for: [exp1], timeout: 0.1)
    }

    func testSchedulerStream() async {
        let scheduler = StreamScheduler<State>()
        await scheduler.setValues([.pending, .completed])

        let exp = expectation(description: "1")
        exp.expectedFulfillmentCount = 2

        let taskExp = expectation(description: "task")
        Task {
            var i = 0
            taskExp.fulfill()
            for await value in await scheduler.waitForValues() {

                i == 0 ? XCTAssertEqual(value, .pending) : XCTAssertEqual(value, .completed)
                i += 1
                exp.fulfill()
            }
        }

        wait(for: [taskExp], timeout: 0.1) // wait till Task is executed

        await scheduler.next()

        print("waiting")

        await scheduler.next()

        await waitForExpectations(timeout: 0.3)
    }
}
