//
//  PaymentAmountCellViewModel.swift
//  Podo
//
//  Created by m3g0byt3 on 25/07/2018.
//  Copyright © 2018 m3g0byt3. All rights reserved.
//

import Foundation
import RxSwift

struct PaymentAmountCellViewModel: PaymentAmountCellViewModelProtocol,
                                   PaymentAmountCellViewModelLinkProtocol,
                                   PaymentAmountCellViewModelInputProtocol,
                                   PaymentAmountCellViewModelOutputProtocol {

    // MARK: - Constants

    private static let buttonOutputSkip = 1
    private static let minTopUpAmount = 1
    private static let maxTopUpAmount = 14_500
    private static let defaultTopUpAmount = 0
    private static let currencySign = "₽"
    // Appending/interpolating with `currencySign` static variable will cause memory leak, so just use literal.
    private static let placeholder = "0₽"
    private static let buttonViewModelRange = [100, 250, 500]

    // MARK: - PaymentAmountCellViewModelProtocol protocol conformance

    var input: PaymentAmountCellViewModelInputProtocol { return self }
    var output: PaymentAmountCellViewModelOutputProtocol { return self }
    var link: PaymentAmountCellViewModelLinkProtocol { return self }

    // MARK: - PaymentAmountCellViewModelLinkProtocol protocol conformance

    let model: Observable<Int>

    // MARK: - PaymentAmountCellViewModelInputProtocol protocol conformance

    let amountInput = PublishSubject<String>()

    // MARK: - PaymentAmountCellViewModelOutputProtocol protocol conformance

    let buttonViewModels: Observable<PaymentAmountCellButtonViewModelProtocol>
    let amountOutput: Observable<String>
    let isAmountValid: Observable<Bool>
    let placeholder: Single<String>

    // MARK: - Initialization

    init() {
        self.placeholder = Single
            .just(PaymentAmountCellViewModel.placeholder)

        let buttonViewModels = PaymentAmountCellViewModel.buttonViewModelRange
            .map { PaymentAmountCellButtonViewModel(value: $0, sign: PaymentAmountCellViewModel.currencySign) }

        self.buttonViewModels = Observable
            .from(buttonViewModels)

        let buttonViewModelInputs = buttonViewModels
            .map { $0.output.title.skip(PaymentAmountCellViewModel.buttonOutputSkip) }

        let amountInputs = [self.amountInput.asObservable()]

        let filteredAmountOutput = Observable
            .merge([buttonViewModelInputs, amountInputs].joined())
            .filterNonNumeric()
            .share(replay: 1, scope: .whileConnected)

        self.amountOutput = filteredAmountOutput
            .map { $0.isEmpty ? $0 : $0.appending(PaymentAmountCellViewModel.currencySign) }

        self.model = filteredAmountOutput
            .map(Int.init)
            .filterNil()

        self.isAmountValid = self.amountOutput
            .filterNonNumeric()
            .map { Int($0) ?? PaymentAmountCellViewModel.defaultTopUpAmount }
            .map { $0 >= PaymentAmountCellViewModel.minTopUpAmount && $0 <= PaymentAmountCellViewModel.maxTopUpAmount }
            .distinctUntilChanged()
            .startWith(false)
    }
}
