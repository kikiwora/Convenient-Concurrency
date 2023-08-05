//  Created by Roman Suvorov (kikiwora)

import Foundation

@propertyWrapper
public class Atomic<Value> {
  // A sequential queue is used for consequential consistency and atomicity of operations
  private lazy var queue: DispatchQueue = .init(label: "com.livescore.AtomicQueue.\(Value.self)")
  private var value: Value

  public var projectedValue: Atomic<Value> { self }   // Projected values ensure mutate() is available from outside of class which uses @Atomic. Hence class.
  public var wrappedValue: Value {
    get { queue.sync { value } }                      // NOTE: Only reading of value is atomic. ⚠️ Mutation of read value is not.
    set { queue.sync { value = newValue } }           // NOTE: Applying new value is atomic
  }

  public init(wrappedValue: Value) {
    self.value = wrappedValue
  }

  /// Allows for atomic mutation of property
  /// - Parameter mutation: A closure to mutate property atomically.
  public func mutate(_ mutation: (inout Value) -> Void) {
    queue.sync {
      mutation(&value)
    }
  }
}
