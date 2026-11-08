//
//  ContainerDeleteConsumer.swift
//  LiveContainer (AirStore fork)
//
//  The store's "Remove from AirBox" writes a marker into the shared group; a sandbox will not let it
//  delete AirBox's own bundles. This consumes those markers: the bundle, its data containers and
//  their keychain items go, then the app list is updated.
//

import Foundation

struct ContainerDeleteResult: Sendable
{
    var appFolders: Set<String> = []
    var dataFolders: Set<String> = []
}

enum ContainerDeleteConsumer
{
    /// Cold-launch variant: runs before the app list is built, so a removed app never appears.
    static func consumeBeforeLoad()
    {
        _ = self.deleteMarked()
    }

    /// Running variant: deletes off the main thread, then drops the rows from the list.
    static func apply(to model: SharedModel)
    {
        DispatchQueue.global(qos: .userInitiated).async
        {
            let result = Self.deleteMarked()
            guard !result.appFolders.isEmpty || !result.dataFolders.isEmpty else { return }

            DispatchQueue.main.async
            {
                model.apps.removeAll { result.appFolders.contains(($0.appInfo.relativeBundlePath as String?) ?? "") }
                model.hiddenApps.removeAll { result.appFolders.contains(($0.appInfo.relativeBundlePath as String?) ?? "") }
                model.appDataFolderNames.removeAll { result.dataFolders.contains($0) }
            }
        }
    }

    private static func deleteMarked() -> ContainerDeleteResult
    {
        var result = ContainerDeleteResult()
        guard let group = LCSharedUtils.appGroupPath() else { return result }

        let markersDirectory = group.appendingPathComponent("ContainerDelete", isDirectory: true)
        guard let markers = try? FileManager.default.contentsOfDirectory(at: markersDirectory, includingPropertiesForKeys: nil) else {
            return result
        }

        let finder = FileManager.default
        for marker in markers
        {
            let folder = marker.lastPathComponent
            defer { try? finder.removeItem(at: marker) }
            guard !folder.isEmpty else { continue }

            let bundleURL = LCPath.bundlePath.appendingPathComponent(folder)
            if let info = LCAppInfo(bundlePath: bundleURL.path)
            {
                for container in info.containers
                {
                    let dataFolder = container.folderName
                    guard !dataFolder.isEmpty else { continue }
                    result.dataFolders.insert(dataFolder)
                    try? finder.removeItem(at: LCPath.dataPath.appendingPathComponent(dataFolder))
                    LCUtils.removeAppKeychain(dataUUID: dataFolder)
                }
            }
            if finder.fileExists(atPath: bundleURL.path)
            {
                try? finder.removeItem(at: bundleURL)
            }
            result.appFolders.insert(folder)
        }
        return result
    }
}
