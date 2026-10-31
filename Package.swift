// swift-tools-version: 5.9
//
// AirBox's engine. This package exists on AirStore's branch of the LiveContainer fork so the vendored
// code stays upstream's: nothing in LiveContainer/ is edited, and what we add is the manifest, the one
// header Apple does not ship (dyld_cache_format.h) and a two-line public API.
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
    "LiveContainer/AirBoxEngine.m",   // ours: the entry point AirBox calls
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
            publicHeadersPath: "Include",   // only the entry point (and the vendored dyld header) is public
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
