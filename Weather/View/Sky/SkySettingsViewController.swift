//
//  SkySettingsViewController.swift
//  Weather
//
//  Created by Fedor Artemenkov on 01.04.26.
//

import UIKit
import SnapKit

final class SkySettingsViewController: UIViewController
{
    private weak var delegate: SkyViewProtocol!
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 16
        return stackView
    }()
    
    private let sunHeightSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 1
        return slider
    }()
    
    private let cloudinessSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 1
        return slider
    }()
    
    private let raininessSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 1
        return slider
    }()
    
    init(delegate: SkyViewProtocol) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        layout()
        configurate()
    }
    
    private func layout()
    {
        view.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview().inset(24)
        }
        
        stackView.addArrangedSubview(wrap(for: "Время суток", sunHeightSlider))
        stackView.addArrangedSubview(wrap(for: "Облачность", cloudinessSlider))
//        stackView.addArrangedSubview(wrap(for: "Дождливость", raininessSlider))
    }
    
    private func configurate()
    {
        view.backgroundColor = .white
        
        sunHeightSlider.addTarget(self, action: #selector(didChangeSunHeight), for: .valueChanged)
        sunHeightSlider.value = delegate.sunHeight
        
        cloudinessSlider.addTarget(self, action: #selector(didChangeCloudiness), for: .valueChanged)
        cloudinessSlider.value = delegate.cloudiness
        
        raininessSlider.addTarget(self, action: #selector(didChangeRaininess), for: .valueChanged)
        raininessSlider.value = delegate.raininess
    }
    
    @objc private func didChangeSunHeight(_ sender: UISlider)
    {
        delegate.sunHeight = sender.value
    }
    
    @objc private func didChangeCloudiness(_ sender: UISlider)
    {
        delegate.cloudiness = sender.value
    }
    
    @objc private func didChangeRaininess(_ sender: UISlider)
    {
        delegate.raininess = sender.value
    }
}

private func wrap(for name: String, _ control: UIControl) -> UIView {
    
    let label = UILabel()
    label.text = name + "\t\t\t"
    
    let stackView = UIStackView(arrangedSubviews: [label, control])
    stackView.axis = .horizontal
    stackView.distribution = .fill
    stackView.alignment = .center
    stackView.spacing = 8
    
    return stackView
}
