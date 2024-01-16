//  Created by Roman Suvorov (kikiwora)

@testable import Convenient_Concurrency
import Nimble
import XCTest

// MARK: - ConvenientDispatch_Tests

final class ConvenientDispatch_Tests: XCTestCase {
  // MARK: - asyncOnMain Tests

  func test_asyncOnMain() {
    var didExecute = false
    var didExecuteOnMain = false

    asyncOnMain {
      didExecute = true
      didExecuteOnMain = Thread.isMainThread
    }

    expect(didExecute).to(
      beFalse(),
      description: "asyncOnMain shall not execute work immediately"
    )
    expect(didExecute).toEventually(
      beTrue(),
      description: "asyncOnMain shall execute work later"
    )
    expect(didExecuteOnMain).toEventually(
      beTrue(),
      description: "asyncOnMain shall execute work on main"
    )
  }

  func test_asyncOnMain_afterNow_withValidPositiveDelay() {
    var didExecute = false
    var didExecuteOnMain = false

    asyncOnMain(after: 0.3) {
      didExecute = true
      didExecuteOnMain = Thread.isMainThread
    }

    expect(didExecute).to(
      beFalse(),
      description: "asyncOnMain(after:) shall not execute work immediately"
    )
    expect(didExecute).toEventually(
      beFalse(),
      timeout: .milliseconds(100),
      description: "asyncOnMain(after:) shall not execute work before specified delay"
    )
    expect(didExecute).toEventually(
      beTrue(),
      timeout: .milliseconds(700),
      description: "asyncOnMain(after:) shall execute work after specified delay"
    )
    expect(didExecuteOnMain).toEventually(
      beTrue(),
      timeout: .milliseconds(700),
      description: "asyncOnMain(after:) shall execute work on main after specified delay"
    )
  }

  func test_asyncOnMain_afterNow_withZeroDelay() {
    var didExecute = false
    var didExecuteOnMain = false

    asyncOnMain(after: .zero) {
      didExecute = true
      didExecuteOnMain = Thread.isMainThread
    }

    expect(didExecute).to(
      beFalse(),
      description: "asyncOnMain(after:) shall not execute work immediately when zero delay is provided"
    )
    expect(didExecute).toEventually(
      beTrue(),
      timeout: .milliseconds(200),
      description: "asyncOnMain(after:) shall execute work shortly after when zero delay is provided"
    )
    expect(didExecuteOnMain).toEventually(
      beTrue(),
      timeout: .milliseconds(200),
      description: "asyncOnMain(after:) shall execute work on main shortly after when zero delay is provided"
    )
  }

  func test_asyncOnMain_afterNow_withNegativeDelay() {
    var didExecute = false
    var didExecuteOnMain = false

    asyncOnMain(after: -0.3) {
      didExecute = true
      didExecuteOnMain = Thread.isMainThread
    }

    expect(didExecute).to(
      beFalse(),
      description: "asyncOnMain(after:) shall not execute work immediately when negative delay is provided"
    )
    expect(didExecute).toEventually(
      beTrue(),
      timeout: .milliseconds(200),
      description: "asyncOnMain(after:) shall execute work shortly after  when negative delay is provided"
    )
    expect(didExecuteOnMain).toEventually(
      beTrue(),
      timeout: .milliseconds(200),
      description: "asyncOnMain(after:) shall execute work on main shortly after when negative delay is provided"
    )
  }

  func test_asyncOnMain_afterDeadline_withValidDeadline() {
    var didExecute = false
    var didExecuteOnMain = false

    asyncOnMain(afterDeadline: .now() + 0.3) {
      didExecute = true
      didExecuteOnMain = Thread.isMainThread
    }

    expect(didExecute).to(
      beFalse(),
      description: "asyncOnMain(afterDeadline:) shall not execute work immediately"
    )
    expect(didExecute).toEventually(
      beFalse(),
      timeout: .milliseconds(100),
      description: "asyncOnMain(afterDeadline:) shall not execute work before specified deadline"
    )
    expect(didExecute).toEventually(
      beTrue(),
      timeout: .milliseconds(700),
      description: "asyncOnMain(afterDeadline:) shall execute work after specified deadline"
    )
    expect(didExecuteOnMain).toEventually(
      beTrue(),
      timeout: .milliseconds(700),
      description: "asyncOnMain(afterDeadline:) shall execute work on main after specified deadline"
    )
  }

  func test_asyncOnMain_afterDeadline_withMissedDeadline() {
    var didExecute = false
    var didExecuteOnMain = false

    asyncOnMain(afterDeadline: .now() - 0.3) {
      didExecute = true
      didExecuteOnMain = Thread.isMainThread
    }

    expect(didExecute).to(
      beFalse(),
      description: "asyncOnMain(afterDeadline:) shall not execute work immediately when specified deadline is missed"
    )
    expect(didExecute).toEventually(
      beTrue(),
      timeout: .milliseconds(200),
      description: "asyncOnMain(afterDeadline:) shall execute work shortly after when specified deadline is missed"
    )
    expect(didExecuteOnMain).toEventually(
      beTrue(),
      timeout: .milliseconds(200),
      description: "asyncOnMain(afterDeadline:) shall execute work on main shortly after when specified deadline is missed"
    )
  }

  func test_asyncOnMain_afterDeadline_withNow() {
    var didExecute = false
    var didExecuteOnMain = false

    asyncOnMain(afterDeadline: .now()) {
      didExecute = true
      didExecuteOnMain = Thread.isMainThread
    }

    expect(didExecute).to(
      beFalse(),
      description: "asyncOnMain(afterDeadline:) shall not execute work immediately when specified deadline is now"
    )
    expect(didExecute).toEventually(
      beTrue(),
      timeout: .milliseconds(200),
      description: "asyncOnMain(afterDeadline:) shall execute work shortly after when specified deadline is now"
    )
    expect(didExecuteOnMain).toEventually(
      beTrue(),
      timeout: .milliseconds(200),
      description: "asyncOnMain(afterDeadline:) shall execute work on main when specified deadline is now"
    )
  }

  // MARK: - syncOnMain Tests

  func test_syncOnMain_whenInvoked_fromMain() {
    var didExecute = false
    var didExecuteOnMain = false

    let didFinishOnMain = expectation(description: "Top-level main context did finish execution")

    DispatchQueue.main.async {
      syncOnMain {
        didExecute = true
        didExecuteOnMain = Thread.isMainThread
      }

      expect(didExecute).to(
        beTrue(),
        description: "syncOnMain shall execute work immediately when called from main thread"
      )
      expect(didExecuteOnMain).to(
        beTrue(),
        description: "syncOnMain shall execute work on main immediately when called from main thread"
      )

      didFinishOnMain.fulfill()
    }

    waitForExpectations(timeout: 1, handler: nil)
  }

  // This test always fails because DispatchQueue in Unit Tests is always associated with Main Thread which throws off Thread.isMainThread detection
  //    func test_syncOnMain_whenInvoked_fromNonMainQueue() {
  //
  //    }

  func test_returning_syncOnMain_whenInvoked_fromMain() {
    var didExecute = false
    var didExecuteOnMain = false
    var returnedValue: String? = nil

    let didFinishOnMain = expectation(description: "Top-level main context did finish execution")

    DispatchQueue.main.async {
      returnedValue = syncOnMain {
        didExecute = true
        didExecuteOnMain = Thread.isMainThread
        return "Success"
      }

      expect(didExecute).to(
        beTrue(),
        description: "returning syncOnMain shall execute work immediately when called from main thread"
      )
      expect(didExecuteOnMain).to(
        beTrue(),
        description: "returning syncOnMain shall execute work on main immediately when called from main thread"
      )
      expect(returnedValue).to(
        equal("Success"),
        description: "returning syncOnMain shall return value immediately when called from main thread"
      )

      didFinishOnMain.fulfill()
    }

    waitForExpectations(timeout: 1, handler: nil)
  }

  // This test always fails because DispatchQueue in Unit Tests is always associated with Main Thread which throws off Thread.isMainThread detection
  //    func test_returning_syncOnMain_whenInvoked_fromNonMainQueue() {
  //
  //    }

  func test_returning_syncOnMain_rethrows_whenInvoked_fromMain() {
    enum TestError: Error {
      case test
    }

    var returnedError: TestError? = nil

    let didFinishOnMain = expectation(description: "Top-level main context did finish execution")

    DispatchQueue.main.async {
      do {
        try syncOnMain {
          throw TestError.test
        }
      } catch {
        returnedError = error as? TestError
      }

      expect(returnedError).to(
        equal(TestError.test),
        description: "rethrowing syncOnMain shall return thrown error immediately when called from main thread"
      )

      didFinishOnMain.fulfill()
    }

    waitForExpectations(timeout: 1, handler: nil)
  }

  // This test always fails because DispatchQueue in Unit Tests is always associated with Main Thread which throws off Thread.isMainThread detection
  //    func test_returning_syncOnMain_rethrows_whenInvoked_fromNonMainQueue() {
  //
  //    }

  // MARK: - performOnMain Tests

  func test_performOnMain_performsImmediately_whenInvoked_fromMain() {
    var didPerformExecute = false
    var didPerformExecuteOnMain = false

    let didFinishOnMain = expectation(description: "Top-level main context did finish execution")

    DispatchQueue.main.async {
      performOnMain {
        didPerformExecute = true
        didPerformExecuteOnMain = Thread.isMainThread
      }

      expect(didPerformExecute).to(
        beTrue(),
        description: "performOnMain shall execute work immediately when invoked from main"
      )

      expect(didPerformExecuteOnMain).to(
        beTrue(),
        description: "performOnMain shall execute work on main"
      )

      didFinishOnMain.fulfill()
    }

    waitForExpectations(timeout: 1, handler: nil)
  }

  // TODO: - This test always fails because DispatchQueue in Unit Tests is always associated with Main Thread which throws off Thread.isMainThread detection
  //    func test_performOnMain_performsAsynchronously_whenInvoked_fromNonMainQueue() {
  //        enum Executions {
  //            case performWork
  //            case afterPerform
  //        }
  //
  //        var didPerformExecuteOnMain: Bool = false
  //        @Atomic var executionOrder: [Executions] = .init()
  //
  //        newQueue.sync {
  //            performOnMain {
  //                executionOrder.append(.performWork)
  //                didPerformExecuteOnMain = Thread.isMainThread
  //            }
  //
  //            executionOrder.append(.afterPerform)
  //        }
  //
  //        expect(executionOrder).to(
  //            equal([.afterPerform]),
  //            description: "performOnMain shall execute work later when invoked off main"
  //        )
  //
  //        expect(executionOrder).toEventually(
  //            equal([.afterPerform, .performWork]),
  //            description: "performOnMain shall eventually execute work on main"
  //        )
  //
  //        expect(didPerformExecuteOnMain).toEventually(
  //            beTrue(),
  //            description: "performOnMain shall execute work on main"
  //        )
  //    }

  // MARK: - queue.async Tests

  func test_asyncOnQueue_afterNow_withValidPositiveDelay() {
    var didExecute = false

    newQueue.async(after: 0.3) {
      didExecute = true
    }

    expect(didExecute).to(
      beFalse(),
      description: "queue.async(after:) shall not execute work immediately"
    )
    expect(didExecute).toEventually(
      beFalse(),
      timeout: .milliseconds(100),
      description: "queue.async(after:) shall not execute work before specified delay"
    )
    expect(didExecute).toEventually(
      beTrue(),
      timeout: .milliseconds(700),
      description: "queue.async(after:) shall execute work after specified delay"
    )
    // NOTE: The fact of execution on newQueue is not verified due to all DispatchQueue being associated with Main Thread which breaks thread detection
  }

//  func test_asyncOnQueue_afterNow_withZeroDelay() {
//    var didExecute = false
//
//    newQueue.async(after: .zero) {
//      didExecute = true
//    }
//
//    expect(didExecute).to(
//      beFalse(),
//      description: "queue.async(after:) shall not execute work immediately when zero delay is provided"
//    )
//    expect(didExecute).toEventually(
//      beTrue(),
//      timeout: .milliseconds(200),
//      description: "queue.async(after:) shall execute work shortly after when zero delay is provided"
//    )
//    // NOTE: The fact of execution on newQueue is not verified due to all DispatchQueue being associated with Main Thread which breaks thread detection
//  }
//
//  func test_asyncOnQueue_afterNow_withNegativeDelay() {
//    var didExecute = false
//
//    newQueue.async(after: -0.3) {
//      didExecute = true
//    }
//
//    expect(didExecute).to(
//      beFalse(),
//      description: "queue.async(after:) shall not execute work immediately when negative delay is provided"
//    )
//    expect(didExecute).toEventually(
//      beTrue(),
//      timeout: .milliseconds(200),
//      description: "queue.async(after:) shall execute work shortly after  when negative delay is provided"
//    )
//    // NOTE: The fact of execution on newQueue is not verified due to all DispatchQueue being associated with Main Thread which breaks thread detection
//  }

  func test_asyncOnQueue_afterDeadline_withValidDeadline() {
    var didExecute = false

    newQueue.async(afterDeadline: .now() + 0.3) {
      didExecute = true
    }

    expect(didExecute).to(
      beFalse(),
      description: "queue.async(afterDeadline:) shall not execute work immediately"
    )
    expect(didExecute).toEventually(
      beFalse(),
      timeout: .milliseconds(100),
      description: "queue.async(afterDeadline:) shall not execute work before specified deadline"
    )
    expect(didExecute).toEventually(
      beTrue(),
      timeout: .milliseconds(700),
      description: "queue.async(afterDeadline:) shall execute work after specified deadline"
    )
    // NOTE: The fact of execution on newQueue is not verified due to all DispatchQueue being associated with Main Thread which breaks thread detection
  }

  func test_asyncOnQueue_afterDeadline_withMissedDeadline() {
    var didExecute = false

    newQueue.async(afterDeadline: .now() - 0.3) {
      didExecute = true
    }

    expect(didExecute).to(
      beFalse(),
      description: "queue.async(afterDeadline:) shall not execute work immediately when specified deadline is missed"
    )
    expect(didExecute).toEventually(
      beTrue(),
      timeout: .milliseconds(200),
      description: "queue.async(afterDeadline:) shall execute work shortly after when specified deadline is missed"
    )
    // NOTE: The fact of execution on newQueue is not verified due to all DispatchQueue being associated with Main Thread which breaks thread detection
  }

  func test_asyncOnQueue_afterDeadline_withNow() {
    var didExecute = false

    newQueue.async(afterDeadline: .now()) {
      didExecute = true
    }

    expect(didExecute).to(
      beFalse(),
      description: "queue.async(afterDeadline:) shall not execute work immediately when specified deadline is now"
    )
    expect(didExecute).toEventually(
      beTrue(),
      timeout: .milliseconds(200),
      description: "queue.async(afterDeadline:) shall execute work shortly after when specified deadline is now"
    )
    // NOTE: The fact of execution on newQueue is not verified due to all DispatchQueue being associated with Main Thread which breaks thread detection
  }
}

// MARK: - Helpers

private extension ConvenientDispatch_Tests {
  // Note: DispatchQueue created in Unit Testing scope are always associated with main thread
  /// Hence, a custom TestingQueue from a target scope is used
  var newQueue: DispatchQueue {
    .init(label: "com.unit-tests.convenient-dispatch.\(UUID())", qos: .background)
  }
}
