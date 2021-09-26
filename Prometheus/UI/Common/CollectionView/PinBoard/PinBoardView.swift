//
//  PinBoardView.swift
//  exKeeper
//
//  Created by Pyretttt on 04.09.2021.
//

import UIKit

protocol PinBoardDelegate: AnyObject {
	/// Обработка введения цифры
	func onNumEntered(num: Int)
	
	/// Удаление числа из прогресса
	func onRemove()
}

final class PinBoardView: UIView {
	
	private enum Values {
		static let defaultSpacing: CGFloat = NumericValues.default
	}
	
	var isEnterEnabled: Bool = true
	weak var delegate: PinBoardDelegate?
	
	// MARK: - Private properties
	
	private var isBiometricEnabled: Bool
	private var pins: [PinInfo] = []
	private lazy var numericPins: [PinInfo] = {
		var result: [PinInfo] = []
		for index in 1...9 {
			result.append(PinInfo(number: index))
		}
		return result
	}()
	private lazy var biometricPin: PinInfo = {
		PinInfo(number: nil, icon: ImageSource.biometry.image, isEnabled: isBiometricEnabled)
	}()
	private lazy var removePin: PinInfo = {
		PinInfo(number: nil, icon: ImageSource.remove.image, isEnabled: false, isRemovePin: true)
	}()
	
	// MARK: - Views
	
	private lazy var collectionLayout: UICollectionViewFlowLayout = {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .vertical
		layout.minimumInteritemSpacing = Values.defaultSpacing
		layout.minimumLineSpacing = Values.defaultSpacing
		
		return layout
	}()

	private lazy var collectionView: UICollectionView = {
		let view = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
		view.dataSource = self
		view.delegate = self
		let backgroundView = UIView()
		view.backgroundColor = .clear
		view.backgroundView = backgroundView
		view.isScrollEnabled = false
		view.allowsSelection = true
		view.register(PinButtonCollectionCell.self, forCellWithReuseIdentifier: PinButtonCollectionCell.reuseID)
		view.translatesAutoresizingMaskIntoConstraints = false
		
		return view
	}()
	
	// MARK: - Lifecycle
	
	init(isBiometricEnabled: Bool,
		 delegate: PinBoardDelegate?){
		self.isBiometricEnabled = isBiometricEnabled
		self.delegate = delegate
		super.init(frame: .zero)
		
		setupPins()
		setupUI()
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Data
	
	func setBiometricsAvailability(_ enabled: Bool) {
		biometricPin.isEnabled = enabled
		setupPins()
	}
	
	func setRemoveOperationAvailability(_ enabled: Bool) {
		removePin.isEnabled = enabled
		setupPins()
	}
	
	private func setupPins() {
		let result: [PinInfo] = numericPins + [biometricPin, PinInfo(number: 0), removePin]
		self.pins = result
		collectionView.reloadData()
	}
	
	// MARK: - Setup UI
	
	private func setupUI() {
		addSubview(collectionView)
		
		setupConstraints()
	}
	
	private func setupConstraints() {
		NSLayoutConstraint.activate([
			collectionView.topAnchor.constraint(equalTo: topAnchor),
			collectionView.heightAnchor.constraint(equalTo: heightAnchor),
			collectionView.widthAnchor.constraint(equalTo: heightAnchor, multiplier: 0.75),
			collectionView.centerXAnchor.constraint(equalTo: centerXAnchor)
		])
	}
	
}

extension PinBoardView: UICollectionViewDataSource {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return pins.count
	}
	
	func collectionView(_ collectionView: UICollectionView,
						cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let model = pins[indexPath.item]
		return dequeCell(collectionView, cellModel: model, indexPath: indexPath)
	}
}

extension PinBoardView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						sizeForItemAt indexPath: IndexPath) -> CGSize {
		let collectionSize = collectionView.frame.size
		let itemsHeight = collectionSize.height - Values.defaultSpacing * 3
		let itemHeight = itemsHeight / 4
		let itemsWidth = collectionSize.width - Values.defaultSpacing * 2
		let itemWidth = itemsWidth / 3
		
		return CGSize(width: itemWidth, height: itemHeight)
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let model = pins[indexPath.item]
		if model.isEnabled {
			if model.isRemovePin { delegate?.onRemove() }
			
			guard let number = model.number else { return }
			delegate?.onNumEntered(num: number)
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
		let model = pins[indexPath.item]
		return model.isEnabled
	}
}

extension PinBoardView {
	
	struct PinInfo: CollectionCellModelType {
		typealias Cell = PinButtonCollectionCell
		
		let number: Int?
		var isEnabled: Bool
		var icon: UIImage?
		var isRemovePin: Bool
		
		init(number: Int?,
			 icon: UIImage? = nil,
			 isEnabled: Bool = true,
			 isRemovePin: Bool = false) {
			self.number = number
			self.icon = icon
			self.isEnabled = isEnabled
			self.isRemovePin = isRemovePin
		}
	}
}