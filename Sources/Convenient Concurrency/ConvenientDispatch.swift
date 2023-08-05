//  Created by Roman Suvorov (kikiwora)

import Foundation

public typealias EmptyClosure = () -> Void
public typealias EmptyBlock = @convention(block) () -> Void

// MARK: - Async on Main

public func asyncOnMain(_ work: @escaping EmptyBlock) {
  DispatchQueue.main.async(execute: work)
}

public func asyncOnMain(after delay: TimeInterval, execute work: @escaping EmptyBlock) {
  guard delay > .zero else {
    DispatchQueue.main.async(execute: work)
    return
  }

  DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: work)
}

public func asyncOnMain(afterDeadline deadline: DispatchTime, execute work: @escaping EmptyBlock) {
  guard deadline > .now() else {
    DispatchQueue.main.async(execute: work)
    return
  }

  DispatchQueue.main.asyncAfter(deadline: deadline, execute: work)
}

// MARK: - Sync on Main

public func performOnMain(_ work: @escaping EmptyBlock) {
  guard Thread.isMainThread else {
    DispatchQueue.main.async(execute: work)
    return
  }

  work()
}

public func syncOnMain(_ work: @escaping EmptyBlock) {
  guard Thread.isMainThread else {
    DispatchQueue.main.sync(execute: work)
    return
  }

  work()
}

public func syncOnMain<T>(_ work: @escaping () throws -> T) rethrows -> T {
  guard Thread.isMainThread else {
    return try DispatchQueue.main.sync(execute: work)
  }

  return try work()
}

// MARK: - Async on DispatchQueue

public extension DispatchQueue {
  func async(after delay: TimeInterval, execute work: @escaping EmptyBlock) {
    guard delay > .zero else {
      self.async(execute: work)
      return
    }
    self.asyncAfter(deadline: .now() + delay, execute: work)
  }

  func async(afterDeadline deadline: DispatchTime, execute work: @escaping EmptyBlock) {
    guard deadline > .now() else {
      self.async(execute: work)
      return
    }
    self.asyncAfter(deadline: deadline, execute: work)
  }
}

// MARK: - DispatchQueue Helpers

public extension DispatchQueue {
  static func getCurrentQueueLabel() -> String {
    DispatchQueue.getSpecific(key: DispatchSpecificKey<String>()) ?? .empty
  }

  static func isCurrentExecution(on queue: DispatchQueue) -> Bool {
    getCurrentQueueLabel() == queue.label
  }
}

// MARK: - Helpers

private extension String {
  static var empty: Self { "" }
}

