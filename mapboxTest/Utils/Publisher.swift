//
//  Publisher.swift
//  mapboxTest
//
//  Created by Artamonov Aleksandr on 08.05.2021.
//

import Combine
import UIKit

extension UIControl {
   struct EventPublisher: Publisher {
      typealias Output = Void
      typealias Failure = Never

      fileprivate var control: UIControl
      fileprivate var event: Event

      func receive<S: Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
         let subscription = EventSubscription(subscriber: subscriber)
         subscriber.receive(subscription: subscription)
         control.addTarget(subscription, action: #selector(subscription.trigger), for: event)
      }
   }

   func publisher(for event: Event) -> EventPublisher {
      EventPublisher(control: self, event: event)
   }
}

private extension UIControl {
   class EventSubscription<S: Subscriber>: Subscription where S.Input == Void {

      var subscriber: S?

      func request(_ demand: Subscribers.Demand) {}

      func cancel() {
         subscriber = nil
      }

      init(subscriber: S) {
         self.subscriber = subscriber
      }

      @objc
      func trigger() {
         _ = subscriber?.receive()
      }
   }
}

extension Publisher {
   var toVoid: AnyPublisher<Void, Self.Failure> {
      map { _ in }
         .eraseToAnyPublisher()
   }
}

func toVoid<T>(t: T) {}
