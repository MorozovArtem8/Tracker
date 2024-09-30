//  Created by Artem Morozov on 29.09.2024.


import Foundation
import YandexMobileMetrica

struct AnalyticsService {
    
    static func activate() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "5166b407-7b80-49b0-9bda-9d44ba8f3f9f") else {
            return
        }
        YMMYandexMetrica.activate(with: configuration)
    }
    
    static func report(event: String, params : [AnyHashable : Any]) {
        YMMYandexMetrica.reportEvent(event, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}
