//
//  CombinedResourceViewController.swift
//  SimpleREST_Example
//
//  Created by Alexandr Gaidukov on 01/08/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import SimpleREST

struct Exchange {
    let startDate: Date
    let startExchange: Double
    let endDate: Date
    let endExchange: Double
    var difference: String {
        return String(format: "%.2f", (endExchange - startExchange) / startExchange * 100) + "%"
    }
    
    static func exchangeRates(from dateFrom: Date, to dateTo: Date) -> CombinedResource<Exchange, APIError> {
        return Rate.rates(at: dateFrom).zipWith(Rate.rates(at: dateTo)) { startRate, endRate in
            return Exchange(startDate: dateFrom, startExchange: startRate.value, endDate: dateTo, endExchange: endRate.value)
        }
    }
}

struct Rate: Decodable {
    let value: Double
    
    enum CodingKeys: String, CodingKey {
        case rates
    }
    
    enum RatesKeys: String, CodingKey {
        case usd = "USD"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rates = try container.nestedContainer(keyedBy: RatesKeys.self, forKey: .rates)
        value = try rates.decode(Double.self, forKey: .usd)
    }
    
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    static func rates(at date: Date) -> Resource<Rate, APIError> {
        return Resource<Rate, APIError>(baseURL: URL(string: "https://api.exchangeratesapi.io")!,
                                        path: Rate.dateFormatter.string(from: date),
                                        params: ["symbols": "USD"],
                                        decoder: JSONDecoder())
    }
}


class CombinedResourceViewController: UIViewController {
    
    @IBOutlet private weak var startDateLabel: UILabel!
    @IBOutlet private weak var endDateLabel: UILabel!
    @IBOutlet private weak var startRateLabel: UILabel!
    @IBOutlet private weak var endRateLabel: UILabel!
    @IBOutlet private weak var differenceLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private let endDate = Date()
    private let startDate = Date().addingTimeInterval(-7 * 24 * 3600) // 1 week ago
    
    private var exchange: Exchange? {
        didSet {
            updateUI()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        startDateLabel.text = Rate.dateFormatter.string(from: startDate)
        endDateLabel.text = Rate.dateFormatter.string(from: endDate)
        loadRates()
    }
    
    private func updateUI() {
        guard let exchange = exchange else { return }
        startRateLabel.text = "\(exchange.startExchange)"
        endRateLabel.text = "\(exchange.endExchange)"
        differenceLabel.text = exchange.difference
    }
    
    private func loadRates() {
        activityIndicator.startAnimating()
        URLSession.shared.load(combinedResource: Exchange.exchangeRates(from: startDate, to: endDate)) {[weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                switch result {
                case .success(let exchange):
                    self?.exchange = exchange
                case .failure(let error):
                    self?.handleError(error)
                }
            }
        }
    }
    
    private func handleError(_ error: HTTPError<APIError>) {
        let message: String
        switch error {
        case .noInternetConnection:
            message = "No internet connection"
        case .responseParseError:
            message = "Response Parsing Error"
        case .serverUnavailable:
            message = "Server unavailable"
        case .custom(let apiError):
            message = apiError.message
        case .other(let code):
            message = "Something went wrong. HTTP code: \(code)"
        }
        
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
