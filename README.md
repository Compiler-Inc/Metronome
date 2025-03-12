# Metronome

An AI-powered musical metronome application. See it in action: 

https://github.com/user-attachments/assets/0ca4dd9c-5a09-4453-aeb1-1491a2e4b39e

## Setup Instructions

### 1. Create a Compiler Developer Account

Before setting up this project, you'll need to:

1. Sign up for an account at [developer.compiler.inc](https://developer.compiler.inc)
2. Create a new app called "Metronome" with the following description:
   > "An AI powered musical metronome"

### 2. Configure Sign in with Apple

This app uses Sign in with Apple for authentication. The complete authentication setup process is documented in detail at:
[https://docs.compiler.inc/features/auth](https://docs.compiler.inc/features/auth)


### 3. Update your app on the Compiler developer dashboard

Psate the following into "Available Functions"

```
[
  {
    "name": "noOp",
    "description": "This is returned if the function cound not be converted into appropriate functions",
    "format": "noOp",
    "parameters": []
  },
  {
    "name": "play",
    "description": "Make the metronome start making sounds",
    "format": "play",
    "parameters": []
  },
  {
    "name": "stop",
    "description": "Make the metronome no longer play sounds",
    "format": "stop",
    "parameters": []
  },
  {
    "name": "setTempo",
    "description": "Set the tempo or speed of the metronome iin \"beats per minute (bpm)\"",
    "format": "setTempo <<bpm>>",
    "parameters": [
      {
        "name": "bpm",
        "type": "number",
        "description": "The target tempo in beats per minute, need to be between 20 and 300",
        "required": true
      }
    ]
  },
  {
    "name": "rampTempo",
    "description": "Increase or decrease the tempo of the metronome over a specified duration,",
    "format": "rampTempo <<bpm>> <<duration>>",
    "parameters": [
      {
        "name": "bpm",
        "type": "number",
        "description": "The target tempo in beats per minute, need to be between 20 and 300",
        "required": true
      },
      {
        "name": "duration",
        "type": "number",
        "description": "The length of time in seconds it will take to reach the target tempo",
        "required": true
      }
    ]
  },
  {
    "name": "changeSound",
    "description": "Change the primary sound of the metronome, which can be referred to as the pulse",
    "format": "changeSound <<sound>>",
    "parameters": [
      {
        "name": "sound",
        "type": "string",
        "description": "This sound has to be one of the following: snap, knock, Acoustic Bass Drum, Bass Drum 1, Side Stick, Acoustic Snare, Hand Clap, Electric Snare, Low Floor Tom, Closed Hi Hat, High Floor Tom, Pedal Hi-Hat, Low Tom, Open Hi-Hat, Low-Mid Tom, Hi Mid Tom, Crash Cymbal 1, High Tom, Ride Cymbal 1, Chinese Cymbal, Ride Bell, Tambourine, Splash Cymbal, Cowbell, Crash Cymbal 2, Vibraslap, Ride Cymbal 2, Hi Bongo, Low Bongo, Mute Hi Conga, Open Hi Conga, Low Conga, High Timbale, Low Timbale, High Agogo, Low Agogo, Cabasa, Maracas, Short Guiro, Long Guiro, Claves, Hi Wood Block, Low Wood Block, Mute Triangle, Open Triangle",
        "required": true
      }
    ]
  },
  {
    "name": "setDownBeat",
    "description": "Change the downbeat sound of the metronome, which can be referred to as the first beat sound",
    "format": "setDownBeat <<sound>>",
    "parameters": [
      {
        "name": "sound",
        "type": "string",
        "description": "This sound has to be one of the following: snap, knock, Acoustic Bass Drum, Bass Drum 1, Side Stick, Acoustic Snare, Hand Clap, Electric Snare, Low Floor Tom, Closed Hi Hat, High Floor Tom, Pedal Hi-Hat, Low Tom, Open Hi-Hat, Low-Mid Tom, Hi Mid Tom, Crash Cymbal 1, High Tom, Ride Cymbal 1, Chinese Cymbal, Ride Bell, Tambourine, Splash Cymbal, Cowbell, Crash Cymbal 2, Vibraslap, Ride Cymbal 2, Hi Bongo, Low Bongo, Mute Hi Conga, Open Hi Conga, Low Conga, High Timbale, Low Timbale, High Agogo, Low Agogo, Cabasa, Maracas, Short Guiro, Long Guiro, Claves, Hi Wood Block, Low Wood Block, Mute Triangle, Open Triangle",
        "required": true
      }
    ]
  },
  {
    "name": "setUpBeat",
    "description": "Change the upbeat sound of the metronome, which can be referred to as the accent",
    "format": "setUpBeat <<sound>>",
    "parameters": [
      {
        "name": "sound",
        "type": "string",
        "description": "This sound has to be one of the following: snap, knock, Acoustic Bass Drum, Bass Drum 1, Side Stick, Acoustic Snare, Hand Clap, Electric Snare, Low Floor Tom, Closed Hi Hat, High Floor Tom, Pedal Hi-Hat, Low Tom, Open Hi-Hat, Low-Mid Tom, Hi Mid Tom, Crash Cymbal 1, High Tom, Ride Cymbal 1, Chinese Cymbal, Ride Bell, Tambourine, Splash Cymbal, Cowbell, Crash Cymbal 2, Vibraslap, Ride Cymbal 2, Hi Bongo, Low Bongo, Mute Hi Conga, Open Hi Conga, Low Conga, High Timbale, Low Timbale, High Agogo, Low Agogo, Cabasa, Maracas, Short Guiro, Long Guiro, Claves, Hi Wood Block, Low Wood Block, Mute Triangle, Open Triangle",
        "required": true
      }
    ]
  },
  {
    "name": "setGapMeasures",
    "description": "After every measure of the metronome playing, we can play any number of silent measures",
    "format": "setGapMeasures <<count>>",
    "parameters": [
      {
        "name": "count",
        "type": "number",
        "description": "The number of measures of silence to be played",
        "required": true
      }
    ]
  },
  {
    "name": "setNumberOfBeats",
    "description": "Sets the number of beats that are shown on the metronome. This is also the top number of a traiditional Time Signature, so the user may say something like \"Set the time signature to 7 4\" and you will only change the first or top number.",
    "format": "setNumberOfBeats <<numberOfBeats>>",
    "parameters": [
      {
        "name": "numberOfBeats",
        "type": "number",
        "description": "The number of beats to show, also the top number of a traditional time signature. Is an Int.",
        "required": true
      }
    ]
  },
  {
    "name": "setColor",
    "description": "Sets the color or style of the metronome. The available colors are \"red\", \"orange\", \"yellow\", \"green\", \"mint\", \"teal\", \"cyan\", \"blue\", \"indigo\", \"purple\", \"pink\", \"brown\", \"black\", \"white\", \"gray\"'. If the prompt is a color not listed, do your best to match it with a corresponding color. For example \"make the style Crimson\" should match with \"red\".",
    "format": "setColor <<color>>",
    "parameters": [
      {
        "name": "color",
        "type": "string",
        "description": "The color or style to set",
        "required": true
      }
    ]
  }
]
```

### 4. Update App ID in Code

After setting up your app on the Compiler dashboard, make sure to update the App ID in the `CompilerManager.swift` file with your own App ID from the dashboard.


## Running the App

Once you've completed the setup steps above, you should be able to build and run the app in Xcode.

## Features

- Adjustable tempo
- Multiple time signatures
- AI-powered functionality through Compiler

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- Active Compiler developer account
