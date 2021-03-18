import Foundation
import RxSwift

example(of: "never") {
    let observable = Observable<Any>.never()
    let disposeBag = DisposeBag()
    
    observable
        .debug("observable", trimOutput: false)
        .subscribe(
            onNext: { element in
                print(element)
            },
            onCompleted: {
                print("Completed")
            },
            onDisposed: {
                print("Disposed")
            }
        )
        .disposed(by: disposeBag)
}
