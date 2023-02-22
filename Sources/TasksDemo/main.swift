//
//  File.swift
//  
//
//  Created by Nikolay Dechko on 1/25/23.
//

import Foundation

/// # Plan:
// Start recording
// Small intro about exmaples, links, source code availability, please interrupt me and ask questions
//

/// # Materials and links:

// https://wojciechkulik.pl/ios/swift-concurrency-things-they-dont-tell-you

// Point Free series about Structured Concurancy (paid content):
// 1. https://www.pointfree.co/collections/concurrency/threads-queues-and-tasks/ep192-concurrency-s-future-tasks-and-cooperation
// 2. https://www.pointfree.co/collections/concurrency/threads-queues-and-tasks/ep193-concurrency-s-future-sendable-and-actors
// 3. https://www.pointfree.co/collections/concurrency/threads-queues-and-tasks/ep194-concurrency-s-future-structured-and-unstructured

/// # Demo Steps:

//1:
funWithProtocols()

//2:
//yeildExample()

//3:
//mainActorIsNotDispatchMain()

//4:
//funWithActors()

//5:
//funWithLocals()

// 6:
// in Tests target
// testWaitForExpectation
// 

// 7
/// # Further reading:
// https://www.pointfree.co/collections/concurrency/clocks/ep210-clocks-controlling-time - Task + Clocks protocol
//Task {
//    Task.sleep(until: <#T##InstantProtocol#>, clock: <#T##Clock#>)
//}

RunLoop.current.run()
