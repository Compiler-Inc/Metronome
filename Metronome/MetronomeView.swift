import AudioKit
import AudioKitEX
import AudioKitUI
import STKAudioKit
import SwiftUI

struct MetronomeData {
    var note: MIDINoteNumber = MIDINoteNumber(GiantSound.closedHiHat.rawValue)
    var startingNote: MIDINoteNumber?
    var accentNote: MIDINoteNumber?
    var tempo: Double = 120.0
    var startTempo: Double = 120.0
    var gapMeasureCount: Int = 0
    var startTime: Date?
    var targetDuration: TimeInterval?
    var targetTempo: Double?
    var isPlaying = false
    var timeSignatureTop: Int = 4
    var beatNoteVelocity = 100.0
    var currentBeat = 0
}

@Observable
class MetronomeConductor: HasAudioEngine {
    let engine = AudioEngine()
    let sampler = AppleSampler()
    var callbackInst = CallbackInstrument()
    let mixer = Mixer()
    var sequencer = Sequencer()
    var timer = Timer()
    
    private let beatUpdateQueue = DispatchQueue(label: "com.metronome.beatUpdate")

    var data = MetronomeData() {
        didSet {
            data.isPlaying ? sequencer.play() : sequencer.stop()
            sequencer.tempo = data.tempo
            updateSequences()
        }
    }

    private func updateCurrentBeat(_ beat: Int) {
        beatUpdateQueue.async { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.data.currentBeat = beat
            }
        }
    }
    
    func rampTempo(bpm: Double, duration: TimeInterval) {
        data.startTempo = data.tempo
        data.targetTempo = bpm
        data.targetDuration = duration
        data.startTime = Date()
    }

    func updateSequences() {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
        var track = sequencer.tracks.first!

        track.length = Double(data.timeSignatureTop)

        track.clear()
        track.sequence.add(noteNumber: data.note, position: 0.0, duration: 0.4)
        let vel = MIDIVelocity(Int(data.beatNoteVelocity))
        for beat in 0 ..< data.timeSignatureTop {
            track.sequence.add(noteNumber: data.note, velocity: vel, position: Double(beat), duration: 0.1)
        }

        track = sequencer.tracks[1]
        track.length = Double(data.timeSignatureTop)
        track.clear()
        for beat in 0 ..< data.timeSignatureTop {
            track.sequence.add(noteNumber: MIDINoteNumber(beat), position: Double(beat), duration: 0.1)
        }
    }

    init() {
        let soundFont = "Giant"
        do {
            try sampler.loadPercussiveSoundFont(soundFont)
        } catch let err {
            print("error: \(err)")
        }

        _ = sequencer.addTrack(for: sampler)

        callbackInst = CallbackInstrument(midiCallback: { [weak self] _, beat, _ in
            self?.updateCurrentBeat(Int(beat))
            print(beat)
        })

        _ = sequencer.addTrack(for: callbackInst)
        updateSequences()

        mixer.addInput(sampler)
        mixer.addInput(callbackInst)

        engine.output = mixer
    }
    
    @objc func fireTimer() {
        if let start = data.startTime, let target = data.targetTempo, let duration = data.targetTempo, let duration = data.targetDuration {
            let elapsedTime = Date().timeIntervalSince(start)
            if elapsedTime < duration {
                data.tempo = data.startTempo + (elapsedTime/duration) * (target - data.startTempo)
            } else {
                data.tempo = target
                data.startTime = nil
                data.targetTempo = nil
                data.targetDuration = nil
            }
        }
    }
}

struct MetronomeView: View {
    @State var conductor = MetronomeConductor()

    func name(noteNumber: MIDINoteNumber) -> String {
        let str = "hihat"
        return str.titleCase()
    }

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Text(conductor.data.isPlaying ? "Stop" : "Start").onTapGesture {
                    conductor.data.isPlaying.toggle()
                }
                VStack {
                    Text("Tempo: \(Int(conductor.data.tempo))")
                    Slider(value: $conductor.data.tempo, in: 60.0 ... 240.0, label: {
                        Text("Tempo")
                    })
                }
            }
            Spacer()

            HStack(spacing: 10) {
                ForEach(0 ..< conductor.data.timeSignatureTop, id: \.self) { index in
                    ZStack {
                        Circle().foregroundColor(conductor.data.currentBeat == index ? .red : .white)
                        Text("\(index + 1)").foregroundColor(.black)
                    }.onTapGesture {
                        conductor.data.timeSignatureTop = index + 1
                    }
                }
                ZStack {
                    Circle().foregroundColor(.white)
                    Text("+").foregroundColor(.black)
                }
                .onTapGesture {
                    conductor.data.timeSignatureTop += 1
                }
            }.padding()

//            FFTView(conductor.reverb)
        }
        .navigationTitle("STK Demo")
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}
