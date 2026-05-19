//
//  OnboardingSlide.swift
//  BootUp
//
//  Created by Eli on 5/18/26.
//

import Foundation

struct OnboardingSlide: Identifiable, Hashable {
    let id: Int
    let videoName: String
    let title: String
    let body: String
}

let onboardingSlides: [OnboardingSlide] = [
    OnboardingSlide(
        id: 0,
        videoName: "permissions",
        title: "GRANT SCREEN TIME AND NOTIFICATION ACCESS",
        body: "Boot Up needs Screen Time and notification permissions to intercept apps. Tap Allow when prompted."
    ),
    OnboardingSlide(
        id: 1,
        videoName: "big1",
        title: "PICK YOUR APPS",
        body: "Tap + and select your apps"
    ),
    OnboardingSlide(
        id: 2,
        videoName: "big2",
        title: "IDENTIFY EACH APP",
        body: "Tap each locked app once to tell Boot Up its name. This lets you save custom timer information per app"
    ),
    OnboardingSlide(
        id: 3,
        videoName: "big3",
        title: "SET CUSTOM BOOT TIME AND GRACE PERIOD",
        body: "Choose a custom boot time (how long you wait to unlock your app) and grace period (how long you have to use the app before Boot Up shuts down the app)"
    ),
    OnboardingSlide(
        id: 4,
        videoName: "big4",
        title: "SET DEFAULT BOOT TIME AND GRACE PERIOD",
        body: "You can also set a default boot time and grace period that will apply to all your chosen apps."
    ),
    OnboardingSlide(
        id: 5,
        videoName: "launch",
        title: "NOW ITS YOUR TURN!",
        body: "This is the minimum set up required. It is highly recommended to set up the Shortcut Automation to improve the Boot Up experience."
    )
]


let automationSlides: [OnboardingSlide] = [
    OnboardingSlide(
        id: 0,
        videoName: "auto1",
        title: "OPEN SHORTCUTS AND SELECT AUTOMATION",
        body: "Open the Shortcuts app on your device. Tap the Automation tab at the bottom. Create a new automation and search for \"App\"."
    ),
    OnboardingSlide(
        id: 1,
        videoName: "auto2",
        title: "SELECT YOUR APP",
        body: "Tap Choose and pick the app you want Boot Up to intercept. Tap the checkmark in the top right to confirm."
    ),
    OnboardingSlide(
        id: 2,
        videoName: "auto3",
        title: "APP AUTOMATION SELECTIONS",
        body: "Toggle \"Is Opened\" on. Toggle \"Run Immediately\" on. Toggle \"Notify When Run\" off. Then tap Next."
    ),
    OnboardingSlide(
        id: 3,
        videoName: "auto4",
        title:"CREATE NEW SHORTCUT",
        body: "Tap \"Create New Shortcut\" under Get Started. Search for \"Launch with BootUp\" and select it."
    ),
    OnboardingSlide(
        id: 4,
        videoName: "auto5",
        title: "SET THE TARGET APP",
        body: "Set Target App to the same app you picked earlier. Tap the checkmark to save. Repeat for each app you've locked."
    ),
    OnboardingSlide(
        id: 5,
        videoName: "auto6",
        title: "CONGRATS YOU NOW HAVE THE FULL BOOT UP EXPERIENCE",
        body: "Thank you for trying Boot Up :)"
    )
]
