import AudioKit

enum GiantSound: Int, CaseIterable {
    case none = 0
    case snap = 26
    case knock = 32
    case acousticBassDrum = 35
    case bassDrum1
    case sideStick
    case acousticSnare
    case handClap
    case electricSnare
    case lowFloorTom
    case closedHiHat
    case highFloorTom
    case pedalHiHat
    case lowTom
    case openHiHat
    case lowMidTom
    case hiMidTom
    case crashCymbal1
    case highTom
    case rideCymbal1
    case chineseCymbal
    case rideBell
    case tambourine
    case splashCymbal
    case cowbell
    case crashCymbal2
    case vibraslap
    case rideCymbal2
    case hiBongo
    case lowBongo
    case muteHiConga
    case openHiConga
    case lowConga
    case highTimbale
    case lowTimbale
    case highAgogo
    case lowAgogo
    case cabasa
    case maracas
    case shortGuiro = 73
    case longGuiro
    case claves
    case hiWoodBlock
    case lowWoodBlock
    case muteTriangle = 80
    case openTriangle
    
}


extension GiantSound: CustomStringConvertible {
    var description: String {
        switch self {
        case .none:             return "None"
        case .snap:             return "Snap"
        case .knock:            return "Knock"
        case .acousticBassDrum: return "Acoustic Bass Drum"
        case .bassDrum1:        return "Bass Drum 1"
        case .sideStick:        return "Side Stick"
        case .acousticSnare:    return "Acoustic Snare"
        case .handClap:         return "Hand Clap"
        case .electricSnare:    return "Electric Snare"
        case .lowFloorTom:      return "Low Floor Tom"
        case .closedHiHat:      return "Closed Hi Hat"
        case .highFloorTom:     return "High Floor Tom"
        case .pedalHiHat:       return "Pedal Hi-Hat"
        case .lowTom:           return "Low Tom"
        case .openHiHat:        return "Open Hi-Hat"
        case .lowMidTom:        return "Low-Mid Tom"
        case .hiMidTom:         return "Hi Mid Tom"
        case .crashCymbal1:     return "Crash Cymbal 1"
        case .highTom:          return "High Tom"
        case .rideCymbal1:      return "Ride Cymbal 1"
        case .chineseCymbal:    return "Chinese Cymbal"
        case .rideBell:         return "Ride Bell"
        case .tambourine:       return "Tambourine"
        case .splashCymbal:     return "Splash Cymbal"
        case .cowbell:          return "Cowbell"
        case .crashCymbal2:     return "Crash Cymbal 2"
        case .vibraslap:        return "Vibraslap"
        case .rideCymbal2:      return "Ride Cymbal 2"
        case .hiBongo:          return "Hi Bongo"
        case .lowBongo:         return "Low Bongo"
        case .muteHiConga:      return "Mute Hi Conga"
        case .openHiConga:      return "Open Hi Conga"
        case .lowConga:         return "Low Conga"
        case .highTimbale:      return "High Timbale"
        case .lowTimbale:       return "Low Timbale"
        case .highAgogo:        return "High Agogo"
        case .lowAgogo:         return "Low Agogo"
        case .cabasa:           return "Cabasa"
        case .maracas:          return "Maracas"
        case .shortGuiro:       return "Short Guiro"
        case .longGuiro:        return "Long Guiro"
        case .claves:           return "Claves"
        case .hiWoodBlock:      return "Hi Wood Block"
        case .lowWoodBlock:     return "Low Wood Block"
        case .muteTriangle:     return "Mute Triangle"
        case .openTriangle:     return "Open Triangle"
        }
    }
}
