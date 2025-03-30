import Foundation

struct LetterProgress: Codable {
    var letter: String
    var attempts: Int
    var successfulAttempts: Int
    var lastAttemptDate: Date
    
    var successRate: Double {
        return attempts > 0 ? Double(successfulAttempts) / Double(attempts) : 0
    }
}

class ProgressTracker {
    static let shared = ProgressTracker()
    
    private let userDefaults = UserDefaults.standard
    private let progressKey = "letterProgress"
    
    private var progress: [String: LetterProgress] {
        get {
            guard let data = userDefaults.data(forKey: progressKey),
                  let progress = try? JSONDecoder().decode([String: LetterProgress].self, from: data) else {
                return [:]
            }
            return progress
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                userDefaults.set(data, forKey: progressKey)
            }
        }
    }
    
    private init() {}
    
    func recordAttempt(for letter: String, wasSuccessful: Bool) {
        var letterProgress = progress[letter] ?? LetterProgress(
            letter: letter,
            attempts: 0,
            successfulAttempts: 0,
            lastAttemptDate: Date()
        )
        
        letterProgress.attempts += 1
        if wasSuccessful {
            letterProgress.successfulAttempts += 1
        }
        letterProgress.lastAttemptDate = Date()
        
        progress[letter] = letterProgress
    }
    
    func getProgress(for letter: String) -> LetterProgress? {
        return progress[letter]
    }
    
    func getAllProgress() -> [LetterProgress] {
        return Array(progress.values)
    }
    
    func getNextRecommendedLetter() -> String {
        let allProgress = getAllProgress()
        let letterSet = Set(allProgress.map { $0.letter })
        
        // Ako ima slova koja još nisu probana
        let unusedLetters = Set(LetterModel.alphabet).subtracting(letterSet)
        if let nextLetter = unusedLetters.first {
            return nextLetter
        }
        
        // Ako su sva slova probana, uzmi ono sa najnižom stopom uspeha
        return allProgress
            .sorted { $0.successRate < $1.successRate }
            .first?.letter ?? LetterModel.alphabet[0]
    }
    
    func resetProgress() {
        progress = [:]
    }
} 