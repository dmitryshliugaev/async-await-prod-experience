# TasksDemo

A description of this package.


Must have knowledge:

Function defenition 

func someFunc() async throws -> Int {
...
}

//How to bridge from non-structued to structured concurancy using Tasks

Task {
    try await someFunc()
}

//What is @MainActor

Task { @MainActor
    try await someFunc()
}

// what is actor
actor MyActor {
    var someVar: Int
}

https://developer.apple.com/news/?id=2o3euotz - three first videos is enough for basic understanding. 

How to use:
1. Open main.swift
2. Uncomment example in Demo section
