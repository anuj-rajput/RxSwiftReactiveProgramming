#  Hello RxSwift

__RxSwift__ is a library for composing asynchronous and event based code by using observable sequences and functional style operators, allowing for parameterized execution via schedulers.

__RxSwift__, in its essence, simpliefies developing asynchronous programs by allowing your code to react to new data and process it in sequential, isolated manner.

## Introduction to asynchronous programming
An iOS app, at any moment, might be dowing any of the following things or more:

- Reacting to button taps
- Animating the keyboard as a text field loses focus
- Downloading a large photo from the Internet
- Saving bits of data to disk
- Playing audio

All of these things seeminly happen at the same time. Whenever keyboard animates out of the screen, the audio in the app doesn't pause until the animation has finished.

All the different bits of the program don't block each other's execution. iOS offers various kinds of APIs that allow you to perform different pieces of work on different threads, across different execution contexts, and perform them across different cores of device's CPU.

Writing code that truly runs in parallel, is very complex when different bits of code need to work with same data. It's hard to know which piece of code updates the data firstm or which code read the latest value.

## Cocoa and UIKit asynchronous APIs

- __`NotificationCenter`__: To execute a piece of code any time an event of interest happens, such as change in device orientation by the user
- __The delegate pattern__: Lets you define an object that acts on behalf or in coordination with another object
- __Grand Central Dispatch__: You can execute blocks of code to be executed sequentially, concurrently or after a delay.
- __Closures__: To create detached pieces of code that you can pass around in your code
- __Combine__: Apple's own framework for writing reactive asynchronous code with Swift introduced in iOS 13

Depending on which APIs you chose to rely on, the degree of difficulty to maintain your ap in a coherent state varies largely.

### Synchronous code
Performing an operation for each element of an array is something you have done plenty of times. It's a very simple yet solid building block of app logic because it guarantees two things: It executes __synchronously__ and the collection is __immutable__ while you iterate over it.

When you iterate over a collection, you do not need to check all the elements are still there and you don't need to rewind back in case another thread inserts an element at the start of the collection.

```swift
var array = [1, 2, 3]
for number in array {
    print(number)
    array = [4, 5, 6]
}
print(array)
```
### Asynchronous code
