import Foundation

func yeildExample() {

    @MainActor
    @Sendable
    func veryLongRunningTaskA() async {
        for i in 0..<100 {
            print(i)
            // 2:
//            await Task.yield()
        }
    }

    @MainActor
    @Sendable
    func veryLongRunningTaskB() async {
        for i in 200..<300 {
            print(i)
            // 2:
//            await Task.yield()
        }
    }

    func executeTwoTasks() {
        Task { @MainActor in
            await veryLongRunningTaskA()
        }

        Task { @MainActor in
            await veryLongRunningTaskB()
        }
    }

    executeTwoTasks()
}


// Dispatch.main is not the same as Task.main
func mainActorIsNotDispatchMain() {
    func ececuteOperationAndCallCompletion(waitUntil operation: @escaping @Sendable () async throws -> Void,
                                           completion: @escaping @Sendable () -> ()) {
        Task { @MainActor  in
            do {
                try await operation()
                completion()
            } catch {
                completion()
            }
        }
    }


    let completion = { @Sendable in
        if !Thread.current.isMainThread {
            print ("captured not Main in Completion")
        }
    }


    ececuteOperationAndCallCompletion(waitUntil: {
        print("operation started")

        if !Thread.current.isMainThread {
            print ("1: captured not Main in operation")
        }


        print("operation completed")
    }, completion: completion)
}



