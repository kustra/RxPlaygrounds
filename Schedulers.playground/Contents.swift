/*
 subscribeOn and observeOn rules
 
 Based on the test below, the following scheduling applies to operation X() in an Rx chain:
 Observable...........X().........subscribe()
 
 1. onSubscribe and onSubscribed:
    i. called on the first subscribeOn scheduler below X in the chain.
    ii. if there is no subscribeOn below X, then called on the thread calling subscribe().
 
 2. onNext, onCompleted, onError:
    i. called on the first observeOn scheduler above X in the chain.
    ii. if there is no observeOn above X, then called on the first subscribeOn scheduler in the chain.
    iii. if there is no subscribeOn, and no observeOn above X in the chain, then it's called on the thread calling subscribe().
 
 3. onDispose:
    ??
 
 */


import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

import RxSwift

var events: EventLog = []

let disposeBag = DisposeBag()
Observable.just(0)
    .debugThread("A")
    .subscribeOn(namedScheduler("subscribeOn-1"))
    .debugThread("B")
    .subscribeOn(namedScheduler("subscribeOn-2"))
    .debugThread("C")
    .observeOn(namedScheduler("observeOn-1"))
    .debugThread("D")
    .subscribeOn(namedScheduler("subscribeOn-3"))
    .debugThread("E")
    .subscribeOn(namedScheduler("subscribeOn-4"))
    .debugThread("F")
    .observeOn(namedScheduler("observeOn-2"))
    .debugThread("G")
    .do(onDispose: {
        prettyPrint(events)
    })
    .subscribe()
    .disposed(by: disposeBag)

/*
 Example debug output:
 
 A       onSubscribe    subscribeOn-1
 A       onSubscribed   subscribeOn-1
 A       onNext         subscribeOn-1
 A       onCompleted    subscribeOn-1
 A       onError        -
 A       onDispose      subscribeOn-1
 
 B       onSubscribe    subscribeOn-2
 B       onSubscribed   subscribeOn-2
 B       onNext         subscribeOn-1
 B       onCompleted    subscribeOn-1
 B       onError        -
 B       onDispose      subscribeOn-2
 
 C       onSubscribe    subscribeOn-3
 C       onSubscribed   subscribeOn-3
 C       onNext         subscribeOn-1
 C       onCompleted    subscribeOn-1
 C       onError        -
 C       onDispose      subscribeOn-1
 
 D       onSubscribe    subscribeOn-3
 D       onSubscribed   subscribeOn-3
 D       onNext         observeOn-1
 D       onCompleted    observeOn-1
 D       onError        -
 D       onDispose      subscribeOn-3
 
 E       onSubscribe    subscribeOn-4
 E       onSubscribed   subscribeOn-4
 E       onNext         observeOn-1
 E       onCompleted    observeOn-1
 E       onError        -
 E       onDispose      subscribeOn-4
 
 F       onSubscribe    NSOperationQueue Main Queue
 F       onSubscribed   NSOperationQueue Main Queue
 F       onNext         observeOn-1
 F       onCompleted    observeOn-1
 F       onError        -
 F       onDispose      observeOn-1
 
 G       onSubscribe    NSOperationQueue Main Queue
 G       onSubscribed   NSOperationQueue Main Queue
 G       onNext         observeOn-2
 G       onCompleted    observeOn-2
 G       onError        -
 G       onDispose      observeOn-2

 */


typealias PointInChain = (name: String, line: UInt)
typealias Event = String
typealias SchedulerName = String
typealias LogsAtPointInChain = [Event: SchedulerName]
typealias EventLog = [(PointInChain, LogsAtPointInChain)]

extension ObservableType {
    func debugThread(_ name: String, line: UInt = #line) -> Observable<E> {
        let pointInChain = (name: name, line: line)
        var pointLogs: LogsAtPointInChain = [:]

        func saveEvent(_ event: Event) {
            pointLogs[event] = OperationQueue.current?.name ?? "<unknown>"
        }

        return self.do(
            onNext: { _ in saveEvent("onNext") },
            onError: { _ in saveEvent("onError") },
            onCompleted: { saveEvent("onCompleted") },
            onSubscribe: { saveEvent("onSubscribe") },
            onSubscribed: { saveEvent("onSubscribed") },
            onDispose: {
                saveEvent("onDispose")
                events.append((pointInChain, pointLogs))
            }
        )
    }
}

func namedScheduler(_ name: String) -> ImmediateSchedulerType {
    let oq = OperationQueue()
    oq.name = name
    return OperationQueueScheduler(operationQueue: oq)
}

func prettyPrint(_ log: EventLog) {
    let eventOrder = ["onSubscribe", "onSubscribed", "onNext", "onCompleted", "onError", "onDispose"]
    let sorted = log.sorted(by: { $0.0.line < $1.0.line })

    var str = ""
    for (pointInChain, pointLogs) in sorted {
        for event in eventOrder {
            str.append(pointInChain.name.padding(toLength: 8, withPad: " ", startingAt: 0))
            str.append(event.padding(toLength: 15, withPad: " ", startingAt: 0))
            str.append(pointLogs[event] ?? "-")
            str.append("\n")
        }
        str.append("\n")
    }
    
    print(str)
}
