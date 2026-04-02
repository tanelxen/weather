//
//  WeatherPresenter.swift
//  Weather
//
//  Created by Fedor Artemenkov on 31.03.26.
//


protocol WeatherPresenter: AnyObject {
    var view: WeatherView? { get set }
    func loadData()
    func refresh()
}
