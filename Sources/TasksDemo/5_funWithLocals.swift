//
//  File.swift
//  
//
//  Created by Nikolay Dechko on 1/30/23.
//

// Example of Task local values:
// A task-local value is a value that can be bound and read in the context of a Task.
// It is implicitly carried with the task,and is accessible by any child tasks the task creates (such as TaskGroup or async let created tasks).
// Further reading: https://www.hackingwithswift.com/quick-start/concurrency/how-to-create-and-use-task-local-values

import Foundation
enum MyLocals {
  @TaskLocal static var id: Int!
}

func funWithLocals() {
    MyLocals.$id.withValue(42) {
        print("withValue:", MyLocals.id!)
        Task {
            MyLocals.$id.withValue(1729) {
                Task {
                    try await Task.sleep(nanoseconds: 2 * NSEC_PER_SEC)
                    print("Task 2:", MyLocals.id!)
                }
            }
            try await Task.sleep(nanoseconds: NSEC_PER_SEC)
            Task {
                print("Task:", MyLocals.id!)
//                await doSomething()
            }
        }
    }
}



