//
//  ContainerManifestPublisher.swift
//  LiveContainer (AirStore fork)
//
//  AirStore shows "Apps in AirBox" from a listing in the group the two apps share; a sandbox will
//  not let it read AirBox's own container. This keeps that listing in step with the app list --
//  written on launch and rewritten whenever the list changes, so an install, a removal, a version
//  change or a hide shows up in the store without either app being restarted.
//

import Combine
import UIKit

final class ContainerManifestPublisher
{
    static let shared = ContainerManifestPublisher()

    private var cancellables = Set<AnyCancellable>()
    private var started = false

    private let iconFileName = "icon.png"

    func start(with model: SharedModel)
    {
        guard !self.started else { return }
        self.started = true

        // @Published replays its current value on subscription, so this also does the first publish.
        model.$apps
            .sink { [weak self] apps in
                self?.publish(apps)
            }
            .store(in: &self.cancellables)
    }

    private func publish(_ apps: [LCAppModel])
    {
        guard let group = LCSharedUtils.appGroupPath() else { return }
        let directory = group.appendingPathComponent("ContainerApps", isDirectory: true)
        let finder = FileManager.default
        do {
            try finder.createDirectory(at: directory, withIntermediateDirectories: true)
        } catch {
            NSLog("[LC] couldn't create the container listing directory: \(error)")
            return
        }

        var keep = Set<String>()
        for app in apps
        {
            let info = app.appInfo
            let relative = info.relativeBundlePath as String?
            let folder = relative.map { ($0 as NSString).lastPathComponent }
                ?? URL(fileURLWithPath: info.bundlePath()).lastPathComponent
            if folder.isEmpty { continue }

            if let icon = info.iconIsDarkIcon(false)?.pngData()
            {
                let iconURL = directory.appendingPathComponent("\(folder)-\(self.iconFileName)")
                if (try? icon.write(to: iconURL, options: .atomic)) != nil
                {
                    keep.insert(iconURL.lastPathComponent)
                }
            }

            let record: [String: Any] = [
                "name": info.displayName() ?? folder,
                "bundleIdentifier": info.bundleIdentifier() ?? "",
                "version": info.version() ?? "",
                "iconFileName": self.iconFileName,
            ]
            let recordURL = directory.appendingPathComponent("\(folder).plist")
            if (record as NSDictionary).write(to: recordURL, atomically: true)
            {
                keep.insert(recordURL.lastPathComponent)
            }
        }

        // Anything the listing still names but the app list no longer has is a guest that was removed.
        if let entries = try? finder.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
        {
            for entry in entries where !keep.contains(entry.lastPathComponent)
            {
                try? finder.removeItem(at: entry)
            }
        }

        NSLog("[LC] published \(apps.count) AirBox app(s) for AirStore")
    }
}
