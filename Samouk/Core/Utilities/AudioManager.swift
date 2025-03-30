import AVFoundation

enum SoundEffect: String {
    case correct = "correct"
    case incorrect = "incorrect"
    case stroke = "stroke"
}

class AudioManager {
    static let shared = AudioManager()
    
    private var audioPlayers: [SoundEffect: AVAudioPlayer] = [:]
    
    private init() {
        setupAudioPlayers()
    }
    
    private func setupAudioPlayers() {
        for effect in [SoundEffect.correct, .incorrect, .stroke] {
            if let path = Bundle.main.path(forResource: effect.rawValue, ofType: "mp3") {
                do {
                    let url = URL(fileURLWithPath: path)
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.prepareToPlay()
                    audioPlayers[effect] = player
                } catch {
                    print("Greška pri učitavanju zvuka: \(error)")
                }
            }
        }
    }
    
    func playSound(_ effect: SoundEffect) {
        audioPlayers[effect]?.play()
    }
    
    func stopSound(_ effect: SoundEffect) {
        audioPlayers[effect]?.stop()
        audioPlayers[effect]?.currentTime = 0
    }
} 