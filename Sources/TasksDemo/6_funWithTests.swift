//
//  File.swift
//  
//
//  Created by Nikolay Dechko on 1/31/23.
//
// 


import Foundation

// show: 1. Simple async task and wait for expectations, then assert
// 1.1 advanced mocks with auto expectations
// 2. Problem with blocked main
// 3. async stream if we have time

enum StepsErrors: Error {
    case someError
}

enum State: Equatable {
    case pending
    case completed
    case failed
}

actor StepsProgress {
    static var pending: Self {
        .init(stepOne: .pending, stepTwo: .pending, stepThree: .pending)
    }

    var stepOne: State
    var stepTwo: State
    var stepThree: State

    var description: String {
        return """
        stepOne: \(stepOne)
        stepTwo: \(stepTwo)
        stepThree: \(stepThree)\n
        """
    }

    init(stepOne: State, stepTwo: State, stepThree: State) {
        self.stepOne = stepOne
        self.stepTwo = stepTwo
        self.stepThree = stepThree
    }

    func updateStepOneWith(_ state: State) {
        stepOne = state
    }

    func updateStepTwoWith(_ state: State) {
        stepTwo = state
    }

    func updateStepThreeWith(_ state: State) {
        stepThree = state
    }
}

protocol ServiceProtocol {
    func someAsyncFunction() async throws -> String
    func executeSteps(progressCallBack: @escaping @Sendable (StepsProgress) async -> Void) async throws
}

class Service: ServiceProtocol, @unchecked Sendable {
    func executeSteps(progressCallBack: @escaping @Sendable (StepsProgress) async -> Void) async throws {
        let currentProgress: StepsProgress = .pending

        do { // First Step
            try await Task.sleep(nanoseconds: NSEC_PER_SEC * 1)
            await currentProgress.updateStepOneWith(.completed)
            await progressCallBack(currentProgress)
        }

        do { // Second Step
            try await Task.sleep(nanoseconds: NSEC_PER_SEC * 1)
            await currentProgress.updateStepTwoWith(.completed)
            await progressCallBack(currentProgress)
        }


        do { // Third Step
            try await Task.sleep(nanoseconds: NSEC_PER_SEC * 1)
            await currentProgress.updateStepThreeWith(.completed)
            await progressCallBack(currentProgress)
        }
    }

    func someAsyncFunction() async throws -> String {
        try await Task.sleep(nanoseconds: NSEC_PER_SEC * 1)
        return "some value"
    }
}

protocol ViewControllerProtocol {
    @MainActor
    func updateUI(progress: String)
}

class ViewController: ViewControllerProtocol {
    func updateUI(progress: String) {
        print(progress)
    }
}

class Presenter: @unchecked Sendable { // UI
    let service: ServiceProtocol
    let viewController: ViewControllerProtocol

    var displayedString: String?

    init(service: ServiceProtocol, viewController: ViewControllerProtocol) {
        self.service = service
        self.viewController = viewController
    }

    func simpleAsyncUpdate() {
        Task {
            do {
                displayedString = try await service.someAsyncFunction() // returns and assigns "some value"
            } catch {
                // no error handling
            }
        }
    }

    func startSteps() {
        Task {
            do {
                try await self.service.executeSteps { progress in
                    await self.viewController.updateUI(progress: await progress.description)
                }
            } catch {

            }
        }
    }
}

func funWithTests() {
    let presenter = Presenter(service: Service(), viewController: ViewController())

    presenter.startSteps()
}
