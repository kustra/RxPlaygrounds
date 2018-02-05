/* Rx-based countdown
 The operation will count down the specified number of seconds while doing some background work. The result of the background work will be delivered with on the count of 0, even if it finishes earlier. If the background work takes longer than the countdown, it will wait at the count of 1 until the result is in.
 Open the Assistant Editor ("View > Assistant Editor > Show Assistant Editor" in Xcode 9) to see the UI.
 */

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

import UIKit
import RxSwift
import RxCocoa

func countdown<T>(_ c: Int,
                  work: Observable<T>,
                  scheduler: SchedulerType = MainScheduler.instance) -> Observable<(countdown: Int, result: T?)> {
    
    let counter = Observable
        .interval(RxTimeInterval(1), scheduler: scheduler)
        .take(c + 1)
        .map({ c - $0 })
    
    return Observable
        .merge(
            work.map({ (countdown: nil, result: $0) }),
            counter.map({ (countdown: $0, result: nil) }))
        .scan((countdown: c, result: nil), accumulator: { (acc, item) in (item.0 ?? acc.0, item.1 ?? acc.1) })
        .map({ (countdown: $0.countdown, result: $0.countdown == 0 ? $0.result : nil) })
        .distinctUntilChanged({ $0.countdown })
}


let scheduler = ConcurrentDispatchQueueScheduler(qos: .background)
let work = Observable.just(()).delaySubscription(2, scheduler: scheduler)

let operation = countdown(3, work: work).publish().refCount()


class MyViewController : UIViewController {
    var label: UILabel!
    
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white
        
        self.label = UILabel()
        label.frame = CGRect(x: 150, y: 200, width: 200, height: 20)
        label.text = "Starting work..."
        label.textColor = .black
        
        view.addSubview(label)
        self.view = view
        
        initWork()
    }

    func initWork() {
        operation
            .map({ $0.result.map({ _ in "Done" }) ?? String($0.countdown) })
            .asDriver(onErrorJustReturn: "Error")
            .drive(label.rx.text)
    }
}

let vc = MyViewController()
PlaygroundPage.current.liveView = vc
