//  Created by Artem Morozov on 25.09.2024.


import Foundation


final class StatisticViewModel {
    
    private let statisticService: StatisticService = StatisticServiceImplementation()

    private(set) var cellData: [CellData] = []
    
    init() {
        guard statisticService.bestPeriod > 0 || statisticService.perfectDays > 0 || statisticService.trackersCompleted > 0 || statisticService.averageValue > 0 else {
            cellData = []
            return
        }
        cellData = [
            CellData(title: "\(statisticService.bestPeriod)", subTitle: "Лучший период"),
            CellData(title: "\(statisticService.perfectDays)", subTitle: "Идеальные дни"),
            CellData(title: "\(statisticService.trackersCompleted)", subTitle: "Трекеров завершено"),
            CellData(title: "\(statisticService.averageValue)", subTitle: "Лучший период")
        ]
    }
    
    func reloadAllData() {
        guard statisticService.bestPeriod > 0 || statisticService.perfectDays > 0 || statisticService.trackersCompleted > 0 || statisticService.averageValue > 0 else {
            cellData = []
            return
        }
        cellData = [
            CellData(title: "\(statisticService.bestPeriod)", subTitle: "Лучший период"),
            CellData(title: "\(statisticService.perfectDays)", subTitle: "Идеальные дни"),
            CellData(title: "\(statisticService.trackersCompleted)", subTitle: "Трекеров завершено"),
            CellData(title: "\(String(format: "%.1f", statisticService.averageValue))", subTitle: "Среднее значение")
        ]
    }

}

