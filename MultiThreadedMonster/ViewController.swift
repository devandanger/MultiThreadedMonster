//
//  ViewController.swift
//  MultiThreadedMonster
//
//  Created by Evan Anger on 3/14/22.
//

import RxCocoa
import RxSwift
import UIKit

class ViewController: UIViewController {
    let disposeBag = DisposeBag()
    @IBOutlet weak var labelThread: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Observable<Int>.interval(RxTimeInterval.milliseconds(200), scheduler: MainScheduler.instance)
            .multiThreadMonster()
//            .bind(to: self.labelThread.rx.text)
//            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { text in
                self.labelThread.text = text
            })
            .disposed(by: self.disposeBag)
    }
}

extension ObservableType where Element == Int {
    func multiThreadMonster() -> Observable<String> {
        return self.map {
            return "Emission \($0)"
        }.flatMap{ v -> Observable<String> in
            let random = Int.random(in: 0...10)
            if random % 2 == 0 {
                return Observable.just(v)
                    .observe(on: MainScheduler.instance)
            } else {
                return Observable.just(v)
                    .observe(on: MainScheduler.asyncInstance)
            }
        }
        .flatMap{ v -> Observable<String> in
            let random = Int.random(in: 0...10)
            if random % 2 == 0 {
                return Observable.just(v)
                    .subscribe(on: ConcurrentDispatchQueueScheduler(queue: DispatchQueue(label: "BG")))
            } else {
                return Observable.just(v)
                    .observe(on: MainScheduler.asyncInstance)
            }
        }
    }
}

