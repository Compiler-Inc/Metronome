import AudioKit
import AudioKitEX
import SwiftUI
import CompilerSwiftAI

@Observable
class Metronome {
    let engine = AudioEngine()
    let sampler = AppleSampler()
    private var promptTap: RawDataTap?
    let promptRecorderInput = Mixer()
    let silencer = Mixer()
    var timer = Timer()

    var processingSteps: [ProcessingStep] = []

    public func addStep(_ text: String) {
        processingSteps.append(ProcessingStep(text: text, isComplete: false))
    }

    public func completeLastStep() {
        if let lastIndex = processingSteps.indices.last {
            processingSteps[lastIndex].isComplete = true
        }
    }

    @objc func fireTimer() {
        if let start = startTime, let target = targetTempo, let duration = targetDuration {
            let elapsedTime = Date().timeIntervalSince(start)
            if elapsedTime < duration {
                tempo = startTempo + (elapsedTime/duration) * (target - startTempo)
            } else {
                tempo = target
                startTime = nil
                targetTempo = nil
                targetDuration = nil
            }
        }
    }
    
    var note: MIDINoteNumber = MIDINoteNumber(GiantSound.closedHiHat.rawValue) {
        didSet {
            setupSequencer()
            sequencer.play()
        }
    }
    
    var startingNote: MIDINoteNumber? {
        didSet {
            setupSequencer()
            sequencer.play()
        }
    }
    var accentNote: MIDINoteNumber? {
        didSet {
            setupSequencer()
            sequencer.play()
        }
    }

    var tempo = 120.0 {
        didSet {
            sequencer.tempo = tempo
        }
    }
    
    var startTempo = 120.0
    var gapMeasureCount = 0 {
        didSet {
            setupSequencer()
            sequencer.play()
        }
    }
    
    var startTime: Date?
    var targetDuration: TimeInterval?
    var targetTempo: Double?

    var isPlaying: Bool = false {
        didSet {
            isPlaying ? sequencer.play() : sequencer.stop()
        }
    }
    

    let mixer = Mixer()
    let sequencer = Sequencer()

    func rampTempo(bpm: Double, duration: TimeInterval) {
        startTempo = tempo
        targetTempo = bpm
        targetDuration = duration
        startTime = Date()
    }

    init() {
        let soundFont = "Giant"
        do {
            try sampler.loadPercussiveSoundFont(soundFont)
        } catch let err {
            print("error: \(err)")
        }
        
        guard let input = engine.input else {
            fatalError()
        }
        promptRecorderInput.addInput(input)
        silencer.addInput(promptRecorderInput)
        silencer.volume = 0
        
        // Connect samplers to mixer
        mixer.addInput(sampler)
        mixer.addInput(silencer)

        // Connect mixer to engine output
        engine.output = mixer
        
        setupSequencer()

        // Start the engine
        do {
            try engine.start()
        } catch {
            print("AudioKit engine failed to start: \(error.localizedDescription)")
        }
    }
    
    private func setupSequencer() {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)


        
        sequencer.tracks.removeAll()

        // Add tracks to sequencer
        sequencer.addTrack(for: sampler)

        // Set tempo
        sequencer.tempo = tempo

        // Add regular pulse on every beat
        for beat in 0..<4 {
            sequencer.tracks[0].add(noteNumber: note, position: Double(beat), duration: 0.1)
        }
        
        if let s = startingNote {
            sequencer.tracks[0].add(noteNumber: s, position: 0, duration: 0.1)
        }
        
        if let a = accentNote {
            sequencer.tracks[0].add(noteNumber: a, position: 1, duration: 0.1)
            sequencer.tracks[0].add(noteNumber: a, position: 3, duration: 0.1)
        }

        // Set length to 4 beats (one bar)
        sequencer.length = Double(gapMeasureCount + 1) * 4.0
        sequencer.loopEnabled = true
    }

}

extension Metronome {
    func startRealtimeTranscription() {
        // Install tap on the input node after lowpass
        promptTap = RawDataTap(promptRecorderInput, bufferSize: 4096) { buffer in
            DeepgramService.shared.sendAudioData(buffer)
        }
        promptTap?.start()
        
        // Start WebSocket connection
        DeepgramService.shared.startRealtimeTranscription()
    }
    
    func stopRealtimeTranscription() {
        promptTap?.stop()
        promptTap = nil
        DeepgramService.shared.stopRealtimeTranscription()
    }
}

extension Metronome {

    func executeCommands(_ commands: [DLMCommand<CommandArgs>]) {
        addStep("Executing commands")
        print("🎯 DLM executing commands: \(commands)")
        completeLastStep()

        for command in commands {
            print("⚡️ Processing command: \(command)")
            guard let metronomeCommand = MetronomeCommand.from(command) else {
                print("❌ Failed to parse command: \(command)")
                continue
            }
            print("✅ Parsed command: \(metronomeCommand)")

            switch metronomeCommand {
            case .play:
                addStep("Starting metronome")
                sequencer.play()
                completeLastStep()

            case .stop:
                addStep("Stopping metronome")
                sequencer.stop()
                completeLastStep()

            case .setTempo(let bpm):
                addStep("Setting tempo to \(bpm) BPM")
                tempo = bpm
                completeLastStep()

            case .rampTempo(let bpm, let duration):
                addStep("Ramping tempo to \(bpm) BPM over \(duration) seconds")
                rampTempo(bpm: bpm, duration: duration)
                completeLastStep()

            case .changeSound(let sound):
                addStep("Setting sound to \(sound)")
                let s = GiantSound.allCases.first(where: {$0.description == sound})
                if let note = s?.rawValue {
                    self.note = MIDINoteNumber(note)
                }
                completeLastStep()

            case .setDownBeat(let sound):
                addStep("Setting downbeat to \(sound)")
                let s = GiantSound.allCases.first(where: {$0.description == sound})
                if let note = s?.rawValue {
                    startingNote = MIDINoteNumber(note)
                }
                completeLastStep()

            case .setUpBeat(let sound):
                addStep("Setting upbeat to \(sound)")
                let s = GiantSound.allCases.first(where: {$0.description == sound})
                if let note = s?.rawValue {
                    accentNote = MIDINoteNumber(note)
                }
                completeLastStep()

            case .setGapMeasures(let count):
                addStep("Setting gap measures to \(count)")
                gapMeasureCount = count
                completeLastStep()

            case .noOp:
                addStep("NoOp")
                print("⚪️ NoOp command received")
                completeLastStep()
            }
        }
        print("✨ Finished executing all commands")
    }
}

struct CommandArgs: Codable, Sendable {
    let bpm: Double?
    let duration: Double?
    let sound: String?
    let count: Int?
}

struct CurrentState: Codable, Sendable {
    let bpm: Double
}
