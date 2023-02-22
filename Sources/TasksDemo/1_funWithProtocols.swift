//
//  File.swift
//  
//
//  Created by Nikolay Dechko on 1/27/23.
//

import Foundation

@MainActor
protocol GeneralMainActorProtocol {
    func someMethodA()
    func someMethodB()
}


protocol IndividualMainActorProtocol {
    @MainActor
    func someOtherMethodA()
    @MainActor
    func someOtherMethodB()
}


class GeneralConformance: GeneralMainActorProtocol, @unchecked Sendable {
    func someMethodA() {

    }

    func someMethodB() {

    }

    func notProtocol() {

    }
}

class IndividualConfromance: IndividualMainActorProtocol, @unchecked Sendable {
    func someOtherMethodA() {

    }

    func someOtherMethodB() {

    }

    func notProtocol() {

    }
}

class C: @unchecked Sendable {
    func notProtocol() {

    }
}

extension C: GeneralMainActorProtocol {
    func someMethodA() {

    }

    func someMethodB() {

    }
}

func funWithProtocols() {
    Task {
        let individual = IndividualConfromance.init()
        await individual.someOtherMethodA()
        individual.notProtocol()

        let general = await GeneralConformance.init()
        await general.someMethodA()
        await general.notProtocol()

        let c = C.init()
        await c.someMethodA()
        c.notProtocol()
    }
}

