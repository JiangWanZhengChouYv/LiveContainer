//
//  LCUIEntry.swift
//  LiveContainer (AirStore fork)
//
//  Upstream dlopens LiveContainerSwiftUI as a framework and calls its synthesized main. AirBox compiles
//  the UI into the app binary instead, so the @main attribute is removed upstream-side and this is the
//  door the engine calls. Keeping it in one place means the engine never needs to know how the UI was
//  linked.
//

import Foundation

@objc(LCUIEntry)
final class LCUIEntry: NSObject
{
    @objc static func run()
    {
        LiveContainerSwiftUIApp.main()
    }
}
