# Boot Up
Boot Up was created to solve my problem of opening instagram reels whenever I had a second to spare. It uses Apple's Screen Time APIs to lock down user selected apps and enforces/integrates a fake loading screen as the only way to unlock them.

<img width="1018" height="469" alt="IMG_4662" src="https://github.com/user-attachments/assets/ce3606b1-5072-4f87-b752-fa5b3a60df22" />

### [Join the Beta test!](https://testflight.apple.com/join/cWjTfdbt)

## What it does
* Open a locked app and get intercepted by a loading screen, loading screen completes and get sent back to the now unlocked app
* Locks selected apps behind a changeable loading or "boot up" screen (5s-300s)
* Relocks apps after a changeable grace period (1m–60m)
* Uses Shortcuts automation for seamless transition to loading screen (only iOS 26 sry)
* Uses Apple's FamilyControls, ManagedSettings, DeviceActivity APIs, also the App Intents framework
* Runs all locally, its only 9mb and most of that is just the tutorial videos lol

## The Psychology
I like playing video games but I found myself scrolling on instagram even when I had the time to make some progress in the video game I am playing at the time. Why? Because instagram reels loads instantly and my PC or Steam deck takes a minute or two to boot up a game. So I thought, why dont I force a loading screen on instagram as well so I will play my game instead of brain rotting. (lesser of two evils?)

## Features
* It's open source because idk what I am doing, I am an Electrical Engineer who just likes to program tools
* It's free because I am an engineer and my income is decent, a donation wouldnt hurt to help pay me back for the apple developer fee
* It is all locally hosted and doesn't send any information anywhere else. I dont care to see what apps you might be using more than you should be
* Cool terminal aesthetic because I wanted it to look like a loading screen from a game. The loading screen is entertaining to me, idc what you think

## How it works (the pipeline in my head and my notes)
```
[1] First Launch
└── open Boot Up
    └──  Onboarding slideshow video tutorial shows
        ├── Get Screen Time authorization
        └── Get Notification authorization
            └── Tap + in top right to choose apps to lock (FamilyActivityPicker)
                ├── saves selection (UserDefaults?? better way to do this?)
                └── locks chosen apps via ManagedSettingsStore
                    ├── user clicks new app shown in the LockedAppsView to add a name to them
                        ├── [Note 1] This is necessary because I need to link the app to a bundleID 
                             and a urlScheme like this, bundleID: com.instagram instagram urlScheme: instagram://
                        ├── [Note 2] This allows me to send the custom boot timer information with the notification or 
                             automation and it also allows me to deeplink back to the app after the loading screen finishes.
                        └── [Note 3] These bundleIDs and urlSchemes are saved in the AppDatabase.swift file for
                              popular apps. If the user to use an app that isnt in the database they can set
                              up a open app shortcut that they can then input into the "Deep Link Fallback"
                              in TokenTimerEditView.
```
```
[2] Static Shielded App Screen (Apple's Shield Configuration Extension)
└── user taps locked app
    ├── iOS displays Static Shield UI
    └── Shortcut automation fires bringing the user to Boot Up
        └── Boot Up starts the loading screen for the app the user opened
```
```
[3] Buttons on static shield screen (Apple's Shield Action Extension)
[Note] This is only if the user didnt set up the shortcut automation
└── user taps primary button (BOOT UP) on the static shield screen
    └── fire notification that includes bundleID to figure out custom boot time set and app name
        └── user taps notification
```
```
[4] Actual Loading Screen
└── Boot Up shows ShieldLoadingView (my cool loading screen)
    └── hits 100%
        ├── Calls ManagedSettingsStore
        │   └── Locked app is temporarily unlocked
        └── Start DeviceActivityMonitorExtension
            └── Schedule user's set grace period
```
```
[5] relock (Apple's Device Activity Monitor Extension)
[Note] I dont really do any of this, the timing and unlocking is all handled by Apple extensions
└── locked app temporarily unclocked
    └── grace time successfully reached
        └── iOS wakes DeviceActivityMonitorExtension in background
            └── Extension reads app token saved in UserDefaults
                └── Extension calls ManagedSettingsStore
                    └── app is relocked
```
## Things to do/figure out
* Make a github pages thing
* ~~Add good onboarding tutorial thing I guess~~
    - Onboarding and automation tutorial added in v1.3
    - NEW: Create a video for shortcut open app option for apps that dont have deeplink baked in
* Add turn off buttons, turn off for every app, turn off per app, potentially turn off grace period or boot timer button option?
* Figure out how to go directly into app without a notification from static shield screen.
    - this was solved by the shortcut automation option in v1.2, its not perfect as it requres user set up so leaving this still here
    - ~~Need to update pipeline in readme to include shortcut automation potential pipeline~~
* make notifications still come through for the shielded apps so I still get instagram dms. also doesnt seem possible with current api
    - I think this can be done with the automation pipeline. Can somehow only enable the shield to relock but otherwise the app appears normal..?
* Shield api locking down widgets for some apps. Somehow unlock the widgets but leave apps locked
* speed up notification coming from primary button in static shield screen somehow
* Figure out @AppStorage to replace UserDefaults, it broke the DeviceActivityMonitor extension before...
* Add a donation link in github repo or maybe even in app donation? apple takes a 30% cut bruh

  
If you have a solution or want to help with any of this please make a pull request. thanks
