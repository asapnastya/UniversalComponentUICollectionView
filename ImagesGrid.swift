//
//  ImagesGrid.swift
//
//  Created by Anastasiia Romanova on 4/13/23.
//

import UIKit

// MARK: - ImagesGridDelegate
protocol ImagesGridDelegate: AnyObject {
    
    func didSelectModel(_ index: Int)
    
    func numberOfItems() -> Int
    func sizeForItem() -> NSCollectionLayoutSize
    func imageForItem(at index: Int) -> UIImage?
}

// MARK: - ImagesGrid
final class ImagesGrid: UIView {
    
    // MARK: - UI
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout.init()
        )
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    // MARK: - Parameters
    private weak var delegate: ImagesGridDelegate?
    
    // MARK: - Configure
    internal func configure(
        delegate: ImagesGridDelegate?,
        selected: Int? = nil
    ) -> Self {
        self.delegate = delegate
        
        registerCells()
        setupConstraints()
        setupLayout()
        
        reloadData(completion: {
            if let selected = selected {
                let indexPath = IndexPath(item: selected, section: .zero)
                
                DispatchQueue.main.async {
                    self.collectionView.scrollToItem(
                        at: indexPath,
                        at: [.centeredVertically, .centeredHorizontally],
                        animated: true
                    )
                }
            }
        })
        
        return self
    }
    
    // MARK: - Setup Collection View
    private func registerCells() {
        collectionView.register(ImagesGridCell.self, forCellWithReuseIdentifier: .imagesGridCellId)
    }
    
    private func setupLayout() {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            self.createImageSection()
        }
        
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    
    // MARK: - Constraints
    private func setupConstraints() {
        addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }
    
    // MARK: - Reload Data
    internal func reloadData(
        completion: (() -> Void)? = nil
    ) {
        
        self.collectionView.reloadData()
        completion?()
    }
}

// MARK: - CreateImageSection
extension ImagesGrid {
    
    private func createImageSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = self.delegate?.sizeForItem() ?? .defaultImagesGroupSize
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        group.contentInsets = NSDirectionalEdgeInsets(
            top: .zero,
            leading: .zero,
            bottom: .zero,
            trailing: 8
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 24,
            leading: 16,
            bottom: 10,
            trailing: .zero
        )
        
        section.orthogonalScrollingBehavior = .groupPaging
        
        return section
    }
}

// MARK: - UICollectionViewDelegate
extension ImagesGrid: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        self.delegate?.didSelectModel(indexPath.row)
    }
}

// MARK: - UICollectionViewDataSource
extension ImagesGrid: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(
        in collectionView: UICollectionView
    ) -> Int {
        .defaultCountOfSections
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        delegate?.numberOfItems() ?? .zero
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: .imagesGridCellId,
            for: indexPath
        ) as? ImagesGridCell
        else { return UICollectionViewCell() }
        
        cell.imageView.image = self.delegate?.imageForItem(at: indexPath.row)
        
        return cell
    }
}

// MARK: - String
private extension String {
    
    static let imagesGridCellId = "imagesGridCellId"
}

// MARK: - Int
private extension Int {
    
    static let defaultCountOfSections = 1
}

// MARK: - NSCollectionLayoutSize
private extension NSCollectionLayoutSize {
    
    static let defaultImagesGroupSize = NSCollectionLayoutSize(
        widthDimension: .absolute(50),
        heightDimension: .absolute(50)
    )
}

// MARK: - ImageCell
final class ImagesGridCell: UICollectionViewCell {
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .red
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 16
        
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        contentView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
}
