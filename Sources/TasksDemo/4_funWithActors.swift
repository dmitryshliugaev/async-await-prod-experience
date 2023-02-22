//
//  File.swift
//  
//
//  Created by Nikolay Dechko on 1/27/23.
//

import Foundation

actor Counter {
    var value: Int = 1

    func increment() {
        value += 1
    }

 //1:
    func decrement() async {
        value -= 1
    }

    //2:
//    func decrement() async {
//        if value > 0 {
//            await Task.yield()
//            value -= 1
//        }
//    }
}


func funWithActors() {
    Task {
        let actor = Counter()

        await withTaskGroup(of: Void.self) { group in
            //2: comment section below
            for _ in 0..<100 {
                group.addTask {
                    await actor.increment()
                }
            }

            for _ in 0..<100 {
                group.addTask {
                    await actor.decrement()
                }
            }
        }

        print(await actor.value) // 1: should be 1l 2: expected to be greater then 0
    }
}
//
//
//actor Counter {
//    var value: Int = 10
//
//    func increment() {
//        value += 1
//    }
//
//// 1:
////    func decrement() async {
////        value -= 1
////    }
//
//    func decrement() async {
//        if value > 0 {
//            await _decrement()
//        }
//    }
//
//    func _decrement() async {
////        await Task.yield()
//        value -= 1
//    }
//}
//
//
//func funWithActors() {
//    Task {
//        let actor = Counter()
//
//        await withTaskGroup(of: Void.self) { group in
////            for _ in 0..<100 {
////                group.addTask {
////                    await actor.increment()
////                }
////            }
//
//            for _ in 0..<100 {
//                group.addTask {
//                    await actor.decrement()
//                }
//            }
//        }
//
//        print(await actor.value)
//    }
//}
