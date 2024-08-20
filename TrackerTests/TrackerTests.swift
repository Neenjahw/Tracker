//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Pavel Popov on 17.08.2024.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    
    func testTrackerListViewControllerForLightUserInterface() {
        let vc = TrackerListViewController()
        
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    }
    
    func testTrackerListViewControllerIphoneSE() {
        let vc = TrackerListViewController()
        
        assertSnapshot(of: vc, as: .image(on: .iPhoneSe))
    }
    
    func testTrackerListViewControllerForDarkUserInterface() {
        let vc = TrackerListViewController()
        
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}
