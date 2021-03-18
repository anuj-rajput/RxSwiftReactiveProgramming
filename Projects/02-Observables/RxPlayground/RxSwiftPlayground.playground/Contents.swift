import Foundation
import RxSwift

example(of: "just, of, from") {
    // 1
    // Define integter constants
    let one = 1
    let two = 2
    let three = 3

    // 2
    // Create an observable sequence of type `Int` using the `just` method with `one` integer constant
    let observable = Observable<Int>.just(one)

    let observable2 = Observable.of(one, two, three)

    let observable3 = Observable.of([one, two, three])

    let observable4 = Observable.from([one, two, three])
}

example(of: "subscribe") {
    let one = 1
    let two = 2
    let three = 3
    
    let observable = Observable.of(one, two, three)
    
    observable.subscribe(onNext: { event in
        print(event)
    })
    
    observable.subscribe { event in
        if let element = event.element {
            print(element)
        }
    }
}

example(of: "empty") {
    let observable = Observable<Void>.empty()
    
    observable.subscribe(
        // 1
        // Handle next events
        onNext: { element in
            print(element)
        },
        // 2
        // Print a message, because `.completed` event does not include an element
        onCompleted: {
            print("Completed")
        }
    )
}

example(of: "never") {
    let observable = Observable<Void>.never()
    
    observable.subscribe(
        onNext: { element in
            print(element)
        },
        onCompleted: {
            print("Completed")
        }
    )
}

example(of: "range") {
    // 1
    // Create an observable using `range` operator, which takes a `start` integer value and a `count` of sequential integers to generate
    let observable = Observable<Int>.range(start: 1, count: 10)
    
    observable
        .subscribe(onNext: { i in
            // 2
            // Calculate and print the nth fibonacci number for each emitted element.
            let n = Double(i)
            
            let fibonacci = Int(
                ((pow(1.61803, n) - pow(0.61803, n)) / 2.23606).rounded()
            )
            
            print(fibonacci)
        })
}


example(of: "dispose") {
    // 1
    // Create and observable of strings
    let observable = Observable.of("A", "B", "C")
    
    // 2
    // Subscribe to the observable, this time saving returned `Disposable` as a local constant called `subscription`
    let subscription = observable.subscribe { (event) in
        // 3
        // Print each `event` in the handler
        print(event)
    }
    
    subscription.dispose()
}


example(of: "DisposeBag") {
    // 1
    // Create a dispose bag.
    let disposeBag = DisposeBag()
    
    // 2
    // Create an observable
    Observable.of("A", "B", "C")
        // 3
        // Subscribe to the observable and print out the emitted events
        .subscribe {
            print($0)
        }
        // 4
        // Add the returned `Disposable` from `subscribe` to the dispose bag.
        .disposed(by: disposeBag)
}


enum MyError: Error {
    case anError
}

example(of: "create") {
    let disposeBag = DisposeBag()
    
    Observable<String>.create { observer in
        // 1
        // Add a `next` event onto the observer. `onNext(_:)` is a convenience method for `on(.next(_:))`
        observer.onNext("1")
        
        observer.onError(MyError.anError)
        
        // 2
        // Add a `compelted` event on to the observer.
        observer.onCompleted()
        
        // 3
        // Add another `next` event.
        observer.onNext("?")
        
        // 4
        // Return a disposable
        return Disposables.create()
    }
    .subscribe(
        onNext: { print($0) },
        onError: { print($0) },
        onCompleted: { print("Completed") },
        onDisposed: { print("Disposed") }
    )
    .disposed(by: disposeBag)
}


example(of: "deferred") {
    let disposeBag = DisposeBag()
    
    // 1
    // Create a Bool flag to flip which observable to return
    var flip = false
    
    // 2
    // Create an observable of Int factory using the deferred operator
    let factory: Observable<Int> = Observable.deferred {
        // 3
        // Toggle `flip`, which happens each time `factory` is subscribed to
        flip.toggle()
        
        // 4
        // Return different observables based on flip
        if flip {
            return Observable.of(1, 2, 3)
        } else {
            return Observable.of(4, 5, 6)
        }
    }
    
    for _ in 0...3 {
        factory.subscribe(onNext: {
            print($0, terminator: "")
        })
        .disposed(by: disposeBag)
        
        print()
    }
}


example(of: "Single") {
    // 1
    // Create a dispose bag to use later.
    let disposeBag = DisposeBag()
    
    // 2
    // Define an Error enum to model some possible errrors
    enum FileReadError: Error {
        case fileNotFound, unreadable, encodingFailed
    }
    
    // 3
    // Implement a function to load text from file on disk that return `Single`
    func loadText(from name: String) -> Single<String> {
        // 4
        // Create and return a  Single
        return Single.create { single in
            // Create a Disposable, because the subscribe closure of `create` expexts it as a return type
            let disposable = Disposables.create()
            
            // Get the path for file name, else add not found error on Single
            guard let path = Bundle.main.path(forResource: name, ofType: "txt") else {
                single(.error(FileReadError.fileNotFound))
                return disposable
            }
            
            // Get the data from the path, else add unreadable error on Single
            guard let data = FileManager.default.contents(atPath: path) else {
                single(.error(FileReadError.unreadable))
                return disposable
            }
            
            // Convert data to string else add encoding error on Single
            guard let contents = String(data: data, encoding: .utf8) else {
                single(.error(FileReadError.encodingFailed))
                return disposable
            }
            
            // Add contents to Single as success and return disposable
            single(.success(contents))
            return disposable
        }
    }
    
    // Call loadText(from:) and pass the root name of text file
    loadText(from: "Copyright")
        // Subscribe to the Single
        .subscribe {
            // Switch on the event and print the string if success else print error
            switch $0 {
            case .success(let string):
                print(string)
            case .error(let error):
                print(error)
            }
        }
        .disposed(by: disposeBag)
}
