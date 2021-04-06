#  Subjects
A common need when developing apps is to manually add new values onto an observable during runtime to emit to subscribers. What you want is something that can act as both an observable and as an __observer__. That something is called a __Subject__.

__PublishSubject__: It’s aptly named, because, like a newspaper publisher, it will receive information and then publish it to subscribers

## What are subjects?
Subjects act as both an observable and an observer.

There are four subject types in RxSwift:
- `PublishSubject`: Starts empty and only emits new elements to subscribers.
- `BehaviorSubject`: Starts with an initial value and replays it or the latest element to new subscribers.
- `ReplaySubject`: Initialized with a buffer size and will maintain a buffer of elements up to that size and replay it to new subscribers.
- `AsyncSubject`: Emits only the last `next` event in the sequence, and only when the subject receives a `completed` event. This is a seldom used kind of subject, and you won’t use it in this book. It’s listed here for the sake of completeness.

`PublishRelay` and `BehaviorRelay`. These wrap their respective subjects, but only accept and relay `next` events. You cannot add a `completed` or `error` event onto relays at all, so they’re great for non-terminating sequences.

## Working with pubilish subjects
Publish subjects come in handy when you simply want subscribers to be notified of new events from the point at which they subscribed, until either they unsubscribe, or the subject has terminated with a `completed` or `error` event.

Top line is the publish subject and the second and third lines are subscribers. The upward-pointing arrows indicate subscriptions, and the downward-pointing arrows represent emitted events.
![publish subjects](https://assets.alexandria.raywenderlich.com/books/rxs/images/0543a50a9da3fee1099ebaf4bc64cbf4c17a6df049058024944a3649ef498dc3/original.png)

When a publish subject receives a `completed` or `error` event, also known as a stop event, it will emit that stop event to new subscribers and it will no longer emit `next` events. However, it will re-emit its stop event to future subscribers.

Sometimes you want to let new subscribers know what was the latest emitted element, even though that element was emitted before the subscription.

Publish subjects don’t replay values to new subscribers. This makes them a good choice to model __events__ such as “user tapped something” or “notification just arrived.”

Behavior subjects work similarly to publish subjects, except they will replay the latest `next` event to new subscribers.

Because `BehaviorSubject` always emits its latest element, you can’t create one without providing an initial value. If you can’t provide an initial value at creation time, that probably means you need to use a `PublishSubject` instead, or model your element as an `Optional`.

Behavior subjects are useful when you want to pre-populate a view with the most recent data. For example, you could bind controls in a user profile screen to a behavior subject, so that the latest values can be used to pre-populate the display while the app fetches fresh data.

## Working with behavior subjects
Replay subjects will temporarily cache, or _buffer_, the latest elements they emit, up to a specified size of your choosing. They will then replay that buffer to new subscribers.

## Working with replay subjects
Creating a replay subject of an __array__ of items. Each emitted element will be an array, so the buffer size will buffer that many arrays.

Explicitly calling `dispose()` on a replay subject like this isn’t something you generally need to do. If you’ve added your subscriptions to a dispose bag, then everything will be disposed of and deallocated when the owner — such as a view controller or view model — is deallocated.

## Working with relays
You add a value onto a relay by using the `accept(_:)` method. In other words, you don’t use `onNext(_:)`. This is because relays can only accept values, i.e., you cannot add an `error` or `completed` event onto them.
A `PublishRelay` wraps a `PublishSubject` and a `BehaviorRelay` wraps a `BehaviorSubject`. What sets relays apart from their wrapped subjects is that they are guaranteed to never terminate.

There is no way to add an `error` or `completed` event onto a relay. Any attempt to do so such as the following will generate a compiler error

Behavior relays also will not terminate with a `completed` or `error` event. Because it wraps a behavior subject, a behavior relay is created with an initial value, and it will replay its latest or initial value to new subscribers. A behavior relay’s special power is that you can ask it for its current value at any time. 

This is very helpful when bridging the imperative world with the reactive world. 
Behavior relays are versatile. You can subscribe to them to be able to react whenever a new `next` event is emitted, just like any other subject. And they can accommodate one-off needs, such as when you just need to check the current value without subscribing to receive updates.
