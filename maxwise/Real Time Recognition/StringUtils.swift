/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Utilities for dealing with recognized strings
*/

import Foundation

extension Character {
	// Given a list of allowed characters, try to convert self to those in list
	// if not already in it. This handles some common misclassifications for
	// characters that are visually similar and can only be correctly recognized
	// with more context and/or domain knowledge. Some examples (should be read
	// in Menlo or some other font that has different symbols for all characters):
	// 1 and l are the same character in Times New Roman
	// I and l are the same character in Helvetica
	// 0 and O are extremely similar in many fonts
	// oO, wW, cC, sS, pP and others only differ by size in many fonts
	func getSimilarCharacter() -> Character {
		let conversionTable = [
			"S": "5",
			"O": "0",
			"I": "1",
			"B": "8"
		]
		// Allow a maximum of two substitutions to handle 's' -> 'S' -> '5'.
		let maxSubstitutions = 2
		var current = String(self)
		var counter = 0
		while counter < maxSubstitutions {
			if let altChar = conversionTable[current] {
				current = altChar
				counter += 1
			} else {
				// Doesn't match anything in our table. Give up.
				break
			}
		}
		
		return current.first!
	}
}

extension String {

	// Returns nil if no number is found.
	func extractNumber() -> String? {
        // Substitute commonly misrecognized characters, for example: 'S' -> '5' or 'l' -> '1'
        var result = ""
		for var char in self {
			char = char.getSimilarCharacter()
			result.append(char)
		}
        
        let separatorSet = CharacterSet(charactersIn: ",.")

        let decimalSet = CharacterSet.decimalDigits
        let invertedDecimalSet = decimalSet.union(separatorSet).inverted

        let digits = result.components(separatedBy: invertedDecimalSet).joined(separator: "")
        print("got: \(self), replaced: \(result)")
        
        // Check if not only separators are present in recognized string
        let filteredComponents = digits.components(separatedBy: separatorSet).filter { $0 != "" }
        guard filteredComponents.count > 0 else {
            return nil
        }
        
        if !digits.isEmpty {
            return digits
        } else {
            return nil
        }
	}
}

class StringTracker {
	var frameIndex: Int64 = 0

	typealias StringObservation = (lastSeen: Int64, count: Int64)
	
	// Dictionary of seen strings. Used to get stable recognition before
	// displaying anything.
	var seenStrings = [String: StringObservation]()
	var bestCount = Int64(0)
	var bestString = ""

	func logFrame(strings: [String]) {
		for string in strings {
			if seenStrings[string] == nil {
				seenStrings[string] = (lastSeen: Int64(0), count: Int64(-1))
			}
			seenStrings[string]?.lastSeen = frameIndex
			seenStrings[string]?.count += 1
			print("Seen \(string) \(seenStrings[string]?.count ?? 0) times")
		}
	
		var obsoleteStrings = [String]()

		// Go through strings and prune any that have not been seen in while.
		// Also find the (non-pruned) string with the greatest count.
		for (string, obs) in seenStrings {
			// Remove previously seen text after 30 frames (~1s).
			if obs.lastSeen < frameIndex - 30 {
				obsoleteStrings.append(string)
			}
			
			// Find the string with the greatest count.
			let count = obs.count
			if !obsoleteStrings.contains(string) && count > bestCount {
				bestCount = Int64(count)
				bestString = string
			}
		}
		// Remove old strings.
		for string in obsoleteStrings {
			seenStrings.removeValue(forKey: string)
		}
		
		frameIndex += 1
	}
	
	func getStableString() -> String? {
		// Require the recognizer to see the same string at least 10 times.
		if bestCount >= 10 {
			return bestString
		} else {
			return nil
		}
	}
	
	func reset(string: String) {
		seenStrings.removeValue(forKey: string)
		bestCount = 0
		bestString = ""
	}
}
