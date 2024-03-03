//
//  Task.swift
//
//
//  Created by Alsey Coleman Miller  on 3/3/24.
//

import Foundation

extension Task where Success == Never, Failure == Never {
    
  /// Suspends the current task for at least the given duration in seconds.
  /// Throws if the task is cancelled while suspended.
  ///
  /// - Parameter seconds: The sleep duration in seconds.
  static func sleep(timeInterval seconds: TimeInterval) async throws {
      try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000.0))
  }
}
