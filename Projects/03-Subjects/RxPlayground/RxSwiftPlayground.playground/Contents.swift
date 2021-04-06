import Foundation
import RxSwift
import RxRelay

example(of: "PublishSubject") {
    let subject = PublishSubject<String>()
    subject.on(.next("Is anyone listening?"))
    
    let subscriptionOne = subject
        .subscribe(onNext: { string in
            print(string)
        })
    
    subject.onNext("1")
    subject.onNext("2")
    
    let subscriptionTwo = subject
        .subscribe { event in
            print("2)", event.element ?? event)
        }
    
    subject.onNext("3")
    
    subscriptionOne.dispose()
    
    subject.onNext("4")
    
    // 1
    // Add a `completed` event on to the subject, using the convenience method. This terminates the subjects's observable sequence
    subject.onCompleted()
    
    // 2
    // Add another element onto the subject. This won't be emitted and printed because the subject has already terminated.
    subject.onNext("5")
    
    // 3
    // Dispose of the subscription
    subscriptionTwo.dispose()
    
    let disposeBag = DisposeBag()
    
    // 4
    // Subscribe to the subject, adding its disposable to a dispose bag
    subject
        .subscribe {
            print("3)", $0.element ?? $0)
        }
        .disposed(by: disposeBag)
    
    subject.onNext("?")
}

// 1
// Define an error type
enum MyError: Error {
    case anError
}

// 2
// Create a helper function to print the element if there is one, an error if there is one or else the event itself
func print<T: CustomStringConvertible>(label: String, event: Event<T>) {
    print(label, (event.element ?? event.error) ?? event)
}

example(of: "BehaviorSubject") {
    // 3
    // Create a new `BehaviorSubject` instance. Initializer takes initial value
    let subject = BehaviorSubject(value: "Initial value")
    let disposeBag = DisposeBag()
    
    subject.onNext("X")
    
    subject
        .subscribe {
            print(label: "1)", event: $0)
        }
        .disposed(by: disposeBag)
    
    // 1
    // Add an error event on to the subject
    subject.onError(MyError.anError)
    
    // 2
    // Create a new subscription on the subject
    subject
        .subscribe {
            print(label: "2)", event: $0)
        }
        .disposed(by: disposeBag)
}

example(of: "ReplaySubject") {
    // 1
    // Create a new replay subject with a buffer size of 2.
    let subject = ReplaySubject<String>.create(bufferSize: 2)
    let disposeBag = DisposeBag()
    
    // 2
    // Add three elements onto the subject
    subject.onNext("1")
    subject.onNext("2")
    subject.onNext("3")
    
    // 3
    // Create two subscription to the subject
    subject
        .subscribe {
            print(label: "1)", event: $0)
        }
        .disposed(by: disposeBag)
    
    subject
        .subscribe {
            print(label: "2)", event: $0)
        }
        .disposed(by: disposeBag)
    
    subject.onNext("4")
    
    subject.onError(MyError.anError)
    subject.dispose()
    
    subject
        .subscribe {
            print(label: "3)", event: $0)
        }
        .disposed(by: disposeBag)
}


example(of: "PublishRelay") {
    let relay = PublishRelay<String>()
    
    let disposeBag = DisposeBag()
    
    relay.accept("Knock knock, anyone home?")
    
    relay
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
    
    relay.accept("1")
}

example(of: "BehaviorRelay") {
    // 1
    // Create a behavior relay with an initial value
    let relay = BehaviorRelay(value: "Initial value")
    let disposeBag = DisposeBag()
    
    // 2
    // Add a new element on to the relay
    relay.accept("New initial value")
    
    // 3
    // Subscribe to the relay
    relay
        .subscribe {
            print(label: "1)", event: $0)
        }
        .disposed(by: disposeBag)
    
    // 1
    // Add a new element on to the relay
    relay.accept("1")
    
    // 2
    // Create a new subscription to the relay
    relay
        .subscribe {
            print(label: "2)", event: $0)
        }
        .disposed(by: disposeBag)
    
    // 3
    // Add another new element on to the relay
    relay.accept("2")
    
    print(relay.value)
}
