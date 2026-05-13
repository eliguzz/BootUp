//
//  AppDatabase.swift
//  BootUp
//
//  Created by Eli on 5/12/26.
//

import Foundation

struct KnownApp {
    let name: String
    let bundleID: String
    let category: String
    let urlScheme: String?

    init(name: String, bundleID: String, category: String, urlScheme: String? = nil) {
        self.name = name
        self.bundleID = bundleID
        self.category = category
        self.urlScheme = urlScheme
    }
}

private let categoryOrder: [String: Int] = [
    "Social":    0,
    "Video":     1,
    "Gaming":    2,
    "News":      3,
    "Messaging": 4,
    "Shopping":  5,
    "Other":     6,
    "Custom":    7,
]

extension KnownApp {
    var categorySortIndex: Int {
        categoryOrder[category] ?? 99
    }
}

let knownApps: [KnownApp] = [

    // Social Media
    KnownApp(name: "TikTok",         bundleID: "com.zhiliaoapp.musically",   category: "Social"),
    KnownApp(name: "Instagram",      bundleID: "com.instagram.Instagram",    category: "Social", urlScheme: "instagram://"),
    KnownApp(name: "X (Twitter)",    bundleID: "com.twitter.twitter",        category: "Social", urlScheme: "twitter://"),
    KnownApp(name: "Facebook",       bundleID: "com.facebook.Facebook",      category: "Social", urlScheme: "fb://"),
    KnownApp(name: "Snapchat",       bundleID: "com.snapchat.snapchat",      category: "Social", urlScheme: "snapchat://"),
    KnownApp(name: "Pinterest",      bundleID: "com.pinterest.Pinterest",    category: "Social", urlScheme: "pinterest://"),
    KnownApp(name: "LinkedIn",       bundleID: "com.linkedin.LinkedIn",      category: "Social", urlScheme: "linkedin://"),
    KnownApp(name: "Tumblr",         bundleID: "com.tumblr.tumblr",          category: "Social", urlScheme: "tumblr://"),
    KnownApp(name: "BeReal",         bundleID: "com.bereal.BeReal",          category: "Social"),
    KnownApp(name: "Threads",        bundleID: "com.burbn.barcelona",        category: "Social"),
    KnownApp(name: "Mastodon",       bundleID: "org.joinmastodon.app",       category: "Social"),
    KnownApp(name: "Bluesky",        bundleID: "xyz.blueskyweb.app",         category: "Social"),

    // Video
    KnownApp(name: "YouTube",        bundleID: "com.google.youtube",         category: "Video",  urlScheme: "youtube://"),
    KnownApp(name: "Twitch",         bundleID: "com.twitch.tv.TwitchApp",    category: "Video",  urlScheme: "twitch://"),
    KnownApp(name: "Netflix",        bundleID: "com.netflix.Netflix",        category: "Video"),
    KnownApp(name: "Hulu",           bundleID: "com.hulu.plus",              category: "Video"),
    KnownApp(name: "Disney+",        bundleID: "com.disney.disneyplus",      category: "Video"),
    KnownApp(name: "HBO Max",        bundleID: "com.hbo.hbonow",             category: "Video"),
    KnownApp(name: "Prime Video",    bundleID: "com.amazon.aiv.AIVApp",      category: "Video"),
    KnownApp(name: "Apple TV",       bundleID: "com.apple.tv",               category: "Video"),

    // Gaming
    KnownApp(name: "Candy Crush",    bundleID: "com.king.candycrushsaga",    category: "Gaming"),
    KnownApp(name: "Clash of Clans", bundleID: "com.supercell.magic",        category: "Gaming"),
    KnownApp(name: "Roblox",         bundleID: "com.roblox.robloxmobile",    category: "Gaming"),
    KnownApp(name: "Pokemon GO",     bundleID: "com.nianticlabs.pokemongo",  category: "Gaming"),
    KnownApp(name: "Fortnite",       bundleID: "com.epicgames.Fortnite",     category: "Gaming"),
    KnownApp(name: "Subway Surfers", bundleID: "com.kiloo.subwaysurf",       category: "Gaming"),
    KnownApp(name: "Among Us",       bundleID: "com.innersloth.amongus",     category: "Gaming"),

    // News
    KnownApp(name: "Reddit",         bundleID: "com.reddit.Reddit",          category: "News",   urlScheme: "reddit://"),
    KnownApp(name: "Apple News",     bundleID: "com.apple.news",             category: "News"),
    KnownApp(name: "CNN",            bundleID: "com.cnn.cnnbrk",             category: "News"),
    KnownApp(name: "BBC News",       bundleID: "uk.co.bbc.news",             category: "News"),
    KnownApp(name: "Flipboard",      bundleID: "com.flipboard.flipboard",    category: "News"),

    // Messaging
    KnownApp(name: "WhatsApp",       bundleID: "net.whatsapp.WhatsApp",      category: "Messaging", urlScheme: "whatsapp://"),
    KnownApp(name: "Telegram",       bundleID: "ph.telegra.Telegraph",       category: "Messaging", urlScheme: "tg://"),
    KnownApp(name: "Discord",        bundleID: "com.hammerandchisel.discord", category: "Messaging", urlScheme: "discord://"),
    KnownApp(name: "Messages",       bundleID: "com.apple.MobileSMS",        category: "Messaging"),
    KnownApp(name: "Messenger",      bundleID: "com.facebook.Messenger",     category: "Messaging"),

    // Shopping
    KnownApp(name: "Amazon",         bundleID: "com.amazon.Amazon",          category: "Shopping"),
    KnownApp(name: "eBay",           bundleID: "com.ebay.iphone",            category: "Shopping"),
    KnownApp(name: "Wish",           bundleID: "com.contextlogic.wish",      category: "Shopping"),
    KnownApp(name: "Etsy",           bundleID: "com.etsy.iphone",            category: "Shopping"),

    // Other
    KnownApp(name: "Safari",         bundleID: "com.apple.mobilesafari",     category: "Other"),
    KnownApp(name: "Chrome",         bundleID: "com.google.chrome.app",      category: "Other"),
    KnownApp(name: "Gmail",          bundleID: "com.google.Gmail",           category: "Other"),
    KnownApp(name: "Spotify",        bundleID: "com.spotify.client",         category: "Other",  urlScheme: "spotify://"),
]

func searchApps(_ query: String) -> [KnownApp] {
    let pool = query.isEmpty ? knownApps : knownApps.filter {
        $0.name.localizedCaseInsensitiveContains(query) ||
        $0.bundleID.localizedCaseInsensitiveContains(query) ||
        $0.category.localizedCaseInsensitiveContains(query)
    }
    return pool.sorted {
        $0.categorySortIndex == $1.categorySortIndex
            ? $0.name < $1.name
            : $0.categorySortIndex < $1.categorySortIndex
    }
}
