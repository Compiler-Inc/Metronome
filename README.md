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

Go to the Swift Import page on the dashboard and paste in the contents of the `CompilerFunction.swift` file, which is just the `CompilerFunctionDef` enum.

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
