
import Foundation
import YandexMobileMetrica

struct AnalyticsService {
    static func activate() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "0c0b4f58-a8fb-4dcd-b74e-c03b15bbb570") else { return }
        
        YMMYandexMetrica.activate(with: configuration)
    }
    
    func report(event: String, screen: String, item: String? = nil) {
        var params: [AnyHashable: Any] = ["screen": screen]
        if let item = item {
            params["item"] = item
        }
        
        YMMYandexMetrica.reportEvent(event, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
        
        print("Reported event: \(event), screen: \(screen), item: \(item ?? "nil")")
    }
}
