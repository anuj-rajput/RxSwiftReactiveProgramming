#  Observables
## What is an observable?
Observables are the heart of Rx. You’ll see “observable”, “observable sequence” and “sequence” used interchangeably in Rx. And, really, they’re all the same thing. You may even see an occasional “stream” thrown around from time to time, especially from developers that come to RxSwift from a different reactive programming environment. “Stream” also refers to the same thing, but, in RxSwift, all the cool kids call it a sequence, not a stream.

An Observable is just a sequence, it is __asynchronous__. Observables produce events over a period of time, which is referred to as __emitting__. Events can contain values, such as numbers or instances of a custom type, or they can be recognized gestures, such as taps.

Best ways to conceptualize this is by using marble diagrams, which are just values plotted on a timeline.

![Marbles](https://assets.alexandria.raywenderlich.com/books/rxs/images/c1161239a67d91b694c2ef4cf9f746b75a8ac5f29e8c540207b89f5792944988/original.png)

Left-to-right arrow represents time, and the numbered circles represent elements of a sequence.

## Lifecycle of an observable
When an observable emits an element, it does so in what’s known as a next event. A vertical bar that represents the end of the road for this observable. This is called a __completed__ event, that is, it’s __terminated__

Sometimes things can go wrong.

![LTR](https://assets.alexandria.raywenderlich.com/books/rxs/images/13887a1c8922fcc3bb2914d01aa5ed5ff38157ee44aed97ea89fd15389a648fd/original.png)

An error occurred in this marble diagram, represented by the red X. The observable emitted an error event containing the __error__. This is the same as when an observable terminates normally with a __completed__ event. If an observable emits an __error__ event, it is also terminated and can no longer emit anything else.

- An observable emits next events that contain elements.
- It can continue to do this until a terminating event is emitted, i.e., an error or completed event.
- Once an observable is terminated, it can no longer emit events.

Events are represented as enumeration cases. 

```swift
/// Represents a sequence event.
///
/// Sequence grammar:
/// ***next\* (error | completed)**
public enum Event<Element> {
    /// Next element is produced.
    case next(Element)
    
    /// Seuquence terminated with an error.
    case error(Swift.Error)
    
    /// Sequence completed successfully.
    case completed
}
```

`next` events contain an instance of some `Element`, error events contain an instance of `Swift.Error` and `completed` events are simply stop events that don’t contain any data.

## Creating observables
The `just` method creates an observable sequence containing just a single element. It is a static method on `Observable`.Iin Rx, methods are referred to as “operators.” 

`of` operator has a __variadic__ parameter, and Swift can infer the `Observable`’s type based on it.

The `just` operator can also take an array as its single element, which may seem a little weird at first. However, it’s the array that is the single element.

The `from` operator creates an observable of individual elements from an array of typed elements. The `from` operator only takes an array.

## Subscribing to observables
`NotificationCenter` broadcasts notifications to observer, however, these observed notifications are different than RxSwift `Observable`s.

Subscribing to an RxSwift observable is fairly similar; you call observing an observable _subscribing_ to it. So instead of `addObserver()`, you use `subscribe()`

An observable won’t send events, or perform any work, until it has a subscriber.
An observable is really a sequence definition, and subscribing to an observable is really more like calling `next()` on an `Iterator` in the Swift standard library.

An observable emits `next`, `error` and `completed` events. A `next` event passes the element being emitted to the handler, and an error event contains an `error` instance.

`subscribe` operator takes a closure parameter that receives an `Event` of type `Int` and doesn’t return anything, and `subscribe` returns a `Disposable`.

When working with observables, you’ll usually be primarily interested in the __elements__ emitted by `next` events, rather than the events themselves.

Event has an `element` property. It’s an optional value, because only `next` events have an element. So you use optional binding to unwrap the element if it’s not `nil`. 

The `empty` operator creates an empty observable sequence with zero elements; it will only emit a `completed` event.
An observable must be defined as a specific type if it cannot be inferred. `Void` is typically used because nothing is going to be emitted. 
They’re handy when you want to return an observable that immediately terminates or intentionally has zero values.

As opposed to the `empty` operator, the `never` operator creates an observable that doesn’t emit anything and never terminates. It can be use to represent an infinite duration. 

## Disposing and terminating
An observable doesn’t do anything until it receives a subscription. It’s the subscription that triggers an observable’s work, causing it to emit new events until an `error` or `completed` event terminates the observable.

To explicitly cancel a subscription, call `dispose()` on it.
Managing each subscription individually would be tedious, so RxSwift includes a `DisposeBag` type. A dispose bag holds disposables — typically added using the `disposed(by:)` method — and will call `dispose()` on each one when the dispose bag is about to be deallocated. This is the pattern you’ll use most frequently: creating and subscribing to an observable, and immediately adding the subscription to a dispose bag.

If you forget to add a subscription to a dispose bag, you will probably leak memory. The Swift compiler should warn you about unused disposables.

Using the `create` operator is another way to specify all the events an observable will emit to subscribers.
The `create` operator takes a single parameter named `subscribe`. Its job is to provide the implementation of calling `subscribe` on the observable. In other words, it defines all the events that will be emitted to subscribers.

`subscribe` operators must return a disposable representing the subscription, so you use `Disposables.create()` to create a disposable.

## Creating observable factories
Rather than creating an observable that waits around for subscribers, it’s possible to create observable factories that vend a new observable to each subscriber.

## Using Traits
Traits are observables with a narrower set of behaviors than regular observables. Their use is optional; you can use a regular observable anywhere you might use a trait instead. Their purpose is to provide a way to more clearly convey your intent to readers of your code or consumers of your API. The context implied by using a trait can help make your code more intuitive.

Three kinds of traits in RxSwift: `Single`, `Maybe` and `Completable`. 

`Single`s will emit either a `success(value)` or `error(error)` event. `success(value)` is actually a combination of the `next` and `completed` events

A `Completable` will only emit a `completed` or `error(error)` event. It will not emit any values. You could use a completable when you only care that an operation completed successfully or failed, such as a file write.

`Maybe` is a mashup of a `Single` and `Completable`. It can either emit a `success(value)`, `completed` or `error(error)`. If you need to implement an operation that could either succeed or fail, and optionally return a value on success, then `Maybe` is your ticket.

## Other operators
The `do` operator enables you to insert __side effects__; that is, handlers to do things that will not change the emitted event in any way. Instead, `do` will just pass the event through to the next operator in the chain. Unlike `subscribe`, `do` also includes an `onSubscribe` handler.

Performing side effects is one way to debug your Rx code. But it turns out that there’s even a better utility for that purpose: the `debug` operator, which will print information about every event for an observable.
