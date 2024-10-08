//  Created by Artem Morozov on 28.09.2024.


import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {

    func testTrackerViewControllerLight() {
        let vc = TrackerViewController()
        vc.overrideUserInterfaceStyle = .light
        assertSnapshot(of: vc, as: .image)
    }
    
    func testTrackerViewControllerBlack() {
        let vc = TrackerViewController()
        vc.overrideUserInterfaceStyle = .dark
        assertSnapshot(of: vc, as: .image)
    }
    
    func testStatisticViewControllerLight() {
        let vc = StatisticViewController()
        vc.overrideUserInterfaceStyle = .light
        assertSnapshot(of: vc, as: .image)
    }
    
    func testStatisticViewControllerBlack() {
        let vc = StatisticViewController()
        vc.overrideUserInterfaceStyle = .dark
        assertSnapshot(of: vc, as: .image)
    }
}
