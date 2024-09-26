//  Created by Artem Morozov on 26.09.2024.

import Foundation

protocol StatisticService {
    var bestPeriod: Int { get }
    var perfectDays: Int { get }
    var trackersCompleted: Int { get }
    var averageValue: Double { get }
    
    func store(allTrackerCategories: [TrackerCategory], allTrackerRecords: [TrackerRecord])
}

final class StatisticServiceImplementation: StatisticService {
    
    private let userDefaults = UserDefaults.standard
    
    var bestPeriod: Int {
        get {
            return userDefaults.integer(forKey: "bestPeriod")
        }
        
        set {
            userDefaults.setValue(newValue, forKey: "bestPeriod")
        }
    }
    
    var perfectDays: Int {
        get {
            return userDefaults.integer(forKey: "perfectDays")
        }
        
        set {
            userDefaults.setValue(newValue, forKey: "perfectDays")
        }
    }
    
    var trackersCompleted: Int {
        get {
            return userDefaults.integer(forKey: "trackersCompleted")
        }
        
        set {
            userDefaults.setValue(newValue, forKey: "trackersCompleted")
        }
    }
    
    var averageValue: Double {
        get {
            return userDefaults.double(forKey: "averageValue")
        }
        
        set {
            userDefaults.setValue(newValue, forKey: "averageValue")
        }
    }
    
    func store(allTrackerCategories: [TrackerCategory], allTrackerRecords: [TrackerRecord]) {
        let allTrackers = allTrackerCategories.flatMap {
            $0.trackers
        }
        perfectDays = getPerfectDays(trackers: allTrackers, allTrackerRecords: allTrackerRecords)
        bestPeriod = getBestPeriod(trackers: allTrackers, allTrackerRecords: allTrackerRecords)
        trackersCompleted = allTrackerRecords.count
        averageValue = getAverageValue(trackers: allTrackers, allTrackerRecords: allTrackerRecords)
    }
    
    private func getAverageValue(trackers: [Tracker], allTrackerRecords: [TrackerRecord]) -> Double {
        guard !trackers.isEmpty && !allTrackerRecords.isEmpty else {return 0}
        
        var dateCounts: [Date: Int] = [:]
        
        for trackerRecord in allTrackerRecords {
            let components = Calendar.current.dateComponents([.year, .month, .day], from: trackerRecord.dateOfCompletion)
            let date = Calendar.current.date(from: components) ?? Date()
            dateCounts[date, default: 0] += 1
        }
        
        let dateCountsArray = Array(dateCounts.values)
        let total = dateCountsArray.reduce(0, +)
        let average = Double(total) / Double(dateCountsArray.count)
        return average
    }
    
    private func getBestPeriod(trackers: [Tracker], allTrackerRecords: [TrackerRecord]) -> Int {
        guard !trackers.isEmpty && !allTrackerRecords.isEmpty else {return 0}
        var maxStreak = 0
        
        
        for tracker in trackers {
            let allTrackersRecords = allTrackerRecords.filter {
                tracker.id == $0.trackerID
            }.sorted { $0.dateOfCompletion < $1.dateOfCompletion }
            
            var currentStreak = 1
            
            if allTrackersRecords.count < 2 {
                maxStreak = max(maxStreak, currentStreak)
                continue
            }
            
            for i in 1..<allTrackersRecords.count {
                let previousDate = allTrackersRecords[i - 1].dateOfCompletion
                let currentDate = allTrackersRecords[i].dateOfCompletion
                
                if Calendar.current.isDate(currentDate, inSameDayAs: Calendar.current.date(byAdding: .day, value: 1, to: previousDate)!) {
                    currentStreak += 1
                } else {
                    maxStreak = max(maxStreak, currentStreak)
                    currentStreak = 1
                }
            }
            
            maxStreak = max(maxStreak, currentStreak)
        }
        
        return maxStreak
    }
    
    private func getPerfectDays(trackers: [Tracker], allTrackerRecords: [TrackerRecord]) -> Int {
        guard !trackers.isEmpty && !allTrackerRecords.isEmpty else {return 0}
        var completionsByDay: [Date: [UUID]] = [:]
        
        for record in allTrackerRecords {
            let calendar = Calendar.current
            let dateWithoutTime = calendar.startOfDay(for: record.dateOfCompletion) // Очищаем время
            completionsByDay[dateWithoutTime, default: []].append(record.trackerID)
        }
        
        var successfulDaysCount = 0
        
        for (date, completedTrackers) in completionsByDay {
            if let dayOfWeek = getDayOfWeek(from: date) {
                // Найдем все трекеры, запланированные на этот день недели
                let notRegularEventForDate = trackers.filter {$0.schedule.isEmpty}
                let trackersForDay = trackers.filter { $0.schedule.contains(dayOfWeek)}
                
                // Проверяем, были ли выполнены все трекеры, запланированные на этот день
                let allCompleted = trackersForDay.allSatisfy { tracker in
                    
                    return completedTrackers.contains(tracker.id)
                } && notRegularEventForDate.allSatisfy { tracker in
                    allTrackerRecords.contains(where: {$0.trackerID == tracker.id})
                }
                
                if allCompleted && (!trackersForDay.isEmpty || !notRegularEventForDate.isEmpty) {
                    successfulDaysCount += 1
                }
            }
        }
        
        return successfulDaysCount
    }
    
    private func getDayOfWeek(from date: Date) -> DaysWeek? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_En") // Устанавливаем локаль на русский
        dateFormatter.dateFormat = "EEEE" // Формат дня недели
        
        let dayOfWeek = dateFormatter.string(from: date)
        return DaysWeek(from: dayOfWeek)
        
    }
}
