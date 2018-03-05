/*
 Demonstrate that even after a dispose call, Rx events can sometimes slip through, and cause crashes if [unowned self] is used in blocks.
 https://github.com/ReactiveX/RxSwift/blob/master/Documentation/GettingStarted.md#disposing
 */

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

import UIKit
import RxSwift
import RxCocoa
import RxOptional

class Example {
    
    private let disposeBag = DisposeBag()
    private let backgroundScheduler: SchedulerType
    
    init(scheduler: SchedulerType) {
        self.backgroundScheduler = scheduler

        Observable.from(1...1000)
            .subscribeOn(backgroundScheduler)
            .debug()
            .subscribe(onNext: { [weak self] _ in
                assert(self != nil)
            })
            .disposed(by: disposeBag)
    }
    
    deinit {
        print("Example deinit")
    }
}

var example: Example?

example = Example(scheduler: ConcurrentDispatchQueueScheduler(qos: DispatchQoS.background))
example = nil

/* Example debug output

 2018-03-05 01:26:50.073: WeakSelfDispose.playground:24 (init(scheduler:)) -> subscribed
 2018-03-05 01:26:50.077: WeakSelfDispose.playground:24 (init(scheduler:)) -> Event next(1)
 Example deinit
 2018-03-05 01:26:50.078: WeakSelfDispose.playground:24 (init(scheduler:)) -> Event next(2)
 Assertion failed: file WeakSelfDispose.playground, line 26
 2018-03-05 01:26:50.078: WeakSelfDispose.playground:24 (init(scheduler:)) -> isDisposed

 */


// Happens for this as well
// example = Example(scheduler: SerialDispatchQueueScheduler(qos: DispatchQoS.background))
// example = nil
