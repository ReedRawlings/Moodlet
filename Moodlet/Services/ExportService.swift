//
//  ExportService.swift
//  Moodlet
//

import Foundation

final class ExportService {
    enum ExportFormat {
        case csv
        case json
    }

    func exportToCSV(entries: [MoodEntry]) -> URL? {
        var csv = "Date,Time,Mood,Mood Value,Activities,Reflection\n"

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"

        for entry in entries.sorted(by: { $0.timestamp < $1.timestamp }) {
            let date = dateFormatter.string(from: entry.timestamp)
            let time = timeFormatter.string(from: entry.timestamp)
            let mood = entry.mood.displayName
            let moodValue = entry.mood.numericValue
            let activities = entry.activityTags.joined(separator: "; ")
            let reflection = (entry.note ?? "")
                .replacingOccurrences(of: ",", with: ";")
                .replacingOccurrences(of: "\n", with: " ")
                .replacingOccurrences(of: "\"", with: "'")

            csv += "\(date),\(time),\(mood),\(moodValue),\"\(activities)\",\"\(reflection)\"\n"
        }

        let fileName = "moodlet_export_\(dateFormatter.string(from: Date())).csv"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            try csv.write(to: tempURL, atomically: true, encoding: .utf8)
            return tempURL
        } catch {
            print("Error writing CSV: \(error)")
            return nil
        }
    }

    func exportToJSON(entries: [MoodEntry]) -> URL? {
        let exportData = entries.map { entry in
            [
                "id": entry.id.uuidString,
                "timestamp": ISO8601DateFormatter().string(from: entry.timestamp),
                "mood": entry.mood.rawValue,
                "moodValue": entry.mood.numericValue,
                "activities": entry.activityTags,
                "note": entry.note ?? ""
            ] as [String: Any]
        }

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let fileName = "moodlet_export_\(dateFormatter.string(from: Date())).json"
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

            try jsonData.write(to: tempURL)
            return tempURL
        } catch {
            print("Error writing JSON: \(error)")
            return nil
        }
    }

    func export(entries: [MoodEntry], format: ExportFormat) -> URL? {
        switch format {
        case .csv:
            return exportToCSV(entries: entries)
        case .json:
            return exportToJSON(entries: entries)
        }
    }
}
