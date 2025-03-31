import SwiftUI
import Charts

struct LearningStatsView: View {
    @State private var selectedTimeRange: TimeRange = .week
    private let progressTracker = ProgressTracker.shared
    private let sampleService = HandwritingSampleService.shared
    
    enum TimeRange: String, CaseIterable {
        case week = "Nedelja"
        case month = "Mesec"
        case all = "Sve"
    }
    
    var body: some View {
        List {
            Section(header: Text("Pregled napretka")) {
                VStack(alignment: .leading, spacing: 15) {
                    // Ukupna statistika
                    HStack {
                        StatCard(
                            title: "Ukupno slova",
                            value: "\(progressTracker.getAllProgress().count)",
                            icon: "textformat.abc"
                        )
                        
                        StatCard(
                            title: "Uspešnost",
                            value: "\(Int(overallSuccessRate * 100))%",
                            icon: "chart.bar.fill"
                        )
                    }
                    
                    // Grafikon napretka
                    Chart {
                        ForEach(filteredProgress) { progress in
                            LineMark(
                                x: .value("Datum", progress.lastAttemptDate),
                                y: .value("Uspešnost", progress.successRate)
                            )
                            .foregroundStyle(Color.blue.gradient)
                        }
                    }
                    .frame(height: 200)
                    .padding(.vertical)
                    
                    // Picker za vremenski opseg
                    Picker("Vremenski opseg", selection: $selectedTimeRange) {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.vertical)
            }
            
            Section(header: Text("Najbolja slova")) {
                ForEach(bestLetters) { progress in
                    HStack {
                        Text(progress.letter)
                            .font(.title2)
                            .frame(width: 40)
                        
                        VStack(alignment: .leading) {
                            Text("Uspešnost: \(Int(progress.successRate * 100))%")
                            Text("Pokušaji: \(progress.attempts)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if let confidence = sampleService.getAverageConfidence(for: progress.letter) {
                            Text("\(Int(confidence * 100))%")
                                .foregroundColor(confidenceColor(for: confidence))
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
            
            Section(header: Text("Slova za vežbanje")) {
                ForEach(lettersToPractice) { progress in
                    HStack {
                        Text(progress.letter)
                            .font(.title2)
                            .frame(width: 40)
                        
                        VStack(alignment: .leading) {
                            Text("Uspešnost: \(Int(progress.successRate * 100))%")
                            Text("Pokušaji: \(progress.attempts)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if let confidence = sampleService.getAverageConfidence(for: progress.letter) {
                            Text("\(Int(confidence * 100))%")
                                .foregroundColor(confidenceColor(for: confidence))
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
        }
        .navigationTitle("Statistika učenja")
    }
    
    private var overallSuccessRate: Double {
        let allProgress = progressTracker.getAllProgress()
        guard !allProgress.isEmpty else { return 0 }
        
        let totalAttempts = allProgress.reduce(0) { $0 + $1.attempts }
        let totalSuccesses = allProgress.reduce(0) { $0 + $1.successfulAttempts }
        
        return totalAttempts > 0 ? Double(totalSuccesses) / Double(totalAttempts) : 0
    }
    
    private var filteredProgress: [LetterProgress] {
        let allProgress = progressTracker.getAllProgress()
        let now = Date()
        
        return allProgress.filter { progress in
            switch selectedTimeRange {
            case .week:
                return progress.lastAttemptDate > now.addingTimeInterval(-7 * 24 * 60 * 60)
            case .month:
                return progress.lastAttemptDate > now.addingTimeInterval(-30 * 24 * 60 * 60)
            case .all:
                return true
            }
        }
    }
    
    private var bestLetters: [LetterProgress] {
        progressTracker.getAllProgress()
            .filter { $0.attempts >= 3 }
            .sorted { $0.successRate > $1.successRate }
            .prefix(5)
            .map { $0 }
    }
    
    private var lettersToPractice: [LetterProgress] {
        progressTracker.getAllProgress()
            .filter { $0.attempts >= 3 }
            .sorted { $0.successRate < $1.successRate }
            .prefix(5)
            .map { $0 }
    }
    
    private func confidenceColor(for confidence: Double) -> Color {
        switch confidence {
        case 0.8...: return .green
        case 0.6...: return .yellow
        default: return .red
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.title3)
                .bold()
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

#Preview {
    NavigationView {
        LearningStatsView()
    }
} 