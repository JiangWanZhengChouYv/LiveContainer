// swift-tools-version: 5.9
//
// AirBox's engine. This package exists on AirStore's branch of the LiveContainer fork so that the two
// bundles that need the engine -- the box and the extension it embeds -- are reading the same sources,
// and what we keep beside upstream's is this manifest and the one header Apple does not ship
// (dyld_cache_format.h).
import PackageDescription

let sources = [
    "LiveContainer/LCBootstrap.m",
    "LiveContainer/LCMachOUtils.m",
    "LiveContainer/LCSharedUtils.m",
    "LiveContainer/Localization.m",
    "LiveContainer/dyld_bypass_validation.m",
    "LiveContainer/utils.m",
    "LiveContainer/Tweaks/Dead10ccFix.m",
    "LiveContainer/Tweaks/Dyld.m",
    "LiveContainer/Tweaks/IDFV.m",
    "LiveContainer/Tweaks/NSBundle+FixCydiaSubstrate.m",
    "LiveContainer/Tweaks/NSFileManager+GuestHooks.m",
    "LiveContainer/Tweaks/NSURLSessionConfiguration+GuestHooks.m",
    "LiveContainer/Tweaks/NSUserDefaults.m",
    "LiveContainer/Tweaks/SecItem.m",
    "LiveContainer/Tweaks/mach_excServer.c",
    "litehook/src/litehook.c",
]

let package = Package(
    name: "AirBoxEngine",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "AirBoxEngine", targets: ["AirBoxEngine"])
    ],
    targets: [
        .target(
            name: "AirBoxEngine",
            path: ".",
            exclude: [
                "LiveContainer/main.c",   // the app's own main(): AirBox has its own entry point
                "Resources",              // upstream's app strings and assets; AirBox brings its own
                "LiveContainerSwiftUI",
                "LaunchAppExtension",
                "LiveContainer.xcodeproj",
            ],
            sources: sources,
            publicHeadersPath: "Include",   // the one header Apple does not ship
            cSettings: [
                .headerSearchPath("LiveContainer"),
                .headerSearchPath("LiveContainer/Tweaks"),
                .headerSearchPath("litehook/src"),
                .headerSearchPath("Include"),
                .unsafeFlags(["-fobjc-arc", "-Wno-deprecated-declarations"]),
            ],
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("Foundation"),
                .linkedLibrary("c++"),
            ]
        )
    ]
)
