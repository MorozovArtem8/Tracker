//  Created by Artem Morozov on 25.09.2024.


import Foundation

final class StatisticViewModel: DataProviderDelegate {
    func didUpdate() {
        
    }
    
    private lazy var dataProvider: DataProviderProtocol? = {
        do {
            try dataProvider = DataProvider(delegate: self)
            return dataProvider
        }
        catch {
            print("Не удалось инициализировать dataProvider")
            return nil
        }
    }()
    
    private var trackers: [Tracker] = []
    private  var allTrackerRecords: [TrackerRecord] = []
    var cellData: [CellData] = []
    
    init() {
        self.trackers = dataProvider?.getAllTrackers() ?? []
        self.allTrackerRecords = dataProvider?.getAllRecords() ?? []
        cellData = [
            CellData(title: "\(getBestPeriod())", subTitle: "Лучший период"),
            CellData(title: "\(allTrackerRecords.count)", subTitle: "Трекеров завершено"),
        ]
    }
    
    func reloadAllData() {
        self.trackers = dataProvider?.getAllTrackers() ?? []
        self.allTrackerRecords = dataProvider?.getAllRecords() ?? []
        cellData = [
            CellData(title: "\(getBestPeriod())", subTitle: "Лучший период"),
            CellData(title: "\(allTrackerRecords.count)", subTitle: "Трекеров завершено"),
        ]
    }
    
    func getBestPeriod() -> Int {
        guard !trackers.isEmpty && !allTrackerRecords.isEmpty else {return 0}
        var maxStreak = 0
        
        
        for tracker in trackers {
            let allTrackersRecords = allTrackerRecords.filter {
                tracker.id == $0.trackerID
            }.sorted { $0.dateOfCompletion < $1.dateOfCompletion }
            
            if allTrackersRecords.count < 2 {
                continue
            }
            
            var currentStreak = 1
            
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
}
