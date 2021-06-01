/*
*  Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.
*/

import UIKit

final class ConferenceParticipantView: UIView {

    @IBOutlet private var labelContainer: UIView!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var backgroundImage: UIImageView!
    @IBOutlet private(set) var streamView: UIView!

    private let cornerRadius: CGFloat = 4

    var isVideoEnabled: Bool = false {
        didSet { streamView.isHidden = !isVideoEnabled }
    }

    var isNameEnabled: Bool = false {
        didSet {
            if let name = name, !name.isEmpty {
                nameLabel.isHidden = !isNameEnabled
                labelContainer.isHidden = !isNameEnabled
            }
        }
    }

    var name: String? {
        get { nameLabel.text }
        set {
            if let newValue = newValue, !newValue.isEmpty, isNameEnabled {
                labelContainer.isHidden = false
            } else {
                labelContainer.isHidden = true
            }
            nameLabel.text = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }

    private func sharedInit() {
        setupFromNib()
        isUserInteractionEnabled = true
        contentMode = .scaleAspectFit
        streamView.clipsToBounds = true
        backgroundImage.layer.cornerRadius = cornerRadius
        labelContainer.layer.cornerRadius = cornerRadius
        streamView.layer.cornerRadius = cornerRadius
    }

    private func setupFromNib() {
        if let view = UINib(
            nibName: String(describing: Self.self),
            bundle: Bundle(for: Self.self)
        ).instantiate(
            withOwner: self,
            options: nil
        ).first as? UIView {
            addSubview(view)
            view.frame = bounds
        } else {
            fatalError("Error loading \(self) from nib")
        }
    }
}
