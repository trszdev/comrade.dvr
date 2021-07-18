import SwiftUI

final class HistoryCellView: UITableViewCell {
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    addSubviews()
    configureSubviews()
    configureConstraints()
  }

  required init?(coder: NSCoder) {
    notImplemented()
  }

  override func setHighlighted(_ highlighted: Bool, animated: Bool) {
    super.setHighlighted(highlighted, animated: animated)
    let whatToDo: () -> Void
    if isSelected {
      whatToDo = setSelected
    } else if highlighted {
      whatToDo = setHighlighted
    } else {
      whatToDo = setNormal
    }
    UIView.defaultAnimation(block: whatToDo)
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    let whatToDo: () -> Void
    if selected {
      whatToDo = setSelected
    } else if isHighlighted {
      whatToDo = setHighlighted
    } else {
      whatToDo = setNormal
    }
    UIView.defaultAnimation(block: whatToDo)
  }

  var theme: Theme = Default.theme {
    didSet {
      customImageView.tintColor = UIColor(theme.accentColor)
      customImageView.backgroundColor = UIColor(theme.startHeaderBackgroundColor)
      if isSelected {
        setSelected()
      } else if isHighlighted {
        setHighlighted()
      } else {
        setNormal()
      }
    }
  }

  var locale: AppLocale = Default.appLocale {
    didSet {
      updateLabels()
    }
  }

  var viewModel: HistoryCellViewModel = Default.historyCellViewModel {
    didSet {
      updateLabels()
      switch viewModel.preview {
      case .cameraPreview:
        customImageView.image = UIImage(sfSymbol: .camera)
      case .microphonePreview:
        customImageView.image = UIImage(sfSymbol: .mic)
      case let .preview(image):
        customImageView.image = image
      }
    }
  }

  func setNormal() {
    setColors(background: theme.mainBackgroundColor, text: theme.textColor)
  }

  func setHighlighted() {
    setColors(background: theme.accentColorHover, text: theme.textColor)
  }

  func setSelected() {
    setColors(background: theme.accentColor, text: theme.startHeaderBackgroundColor)
  }

  private func updateLabels() {
    titleLabel.text = locale.timeOnly(date: viewModel.date)
    let parts = [
      "\(locale.durationString): \(locale.assetDuration(viewModel.duration))",
      "\(locale.sizeString): \(locale.assetSize(viewModel.fileSize))",
    ]
    descriptionLabel.text = parts.joined(separator: "\n")
  }

  private func setColors(background: Color, text: Color) {
    backgroundColor = UIColor(background)
    titleLabel.textColor = UIColor(text)
    descriptionLabel.textColor = UIColor(text)
  }

  private func configureConstraints() {
    titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    descriptionLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    customImageView.setContentCompressionResistancePriority(.required, for: .vertical)
    textContainer.setContentCompressionResistancePriority(.required, for: .vertical)
    container.setContentCompressionResistancePriority(.required, for: .vertical)
    NSLayoutConstraint.activate([
      customImageView.widthAnchor.constraint(equalToConstant: 60),
      customImageView.heightAnchor.constraint(equalToConstant: 60),
      contentView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: -spacing),
      contentView.topAnchor.constraint(equalTo: container.topAnchor, constant: -spacing),
      contentView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: spacing),
      contentView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: spacing),
    ])
  }

  private func configureSubviews() {
    for view in [customImageView, textContainer, container, titleLabel, descriptionLabel] {
      view.translatesAutoresizingMaskIntoConstraints = false
    }
    selectedBackgroundView = UIView()
    textContainer.axis = .vertical
    textContainer.spacing = 0
    container.axis = .horizontal
    container.spacing = 10
    container.alignment = .top
    titleLabel.font = UIFont.preferredFont(forTextStyle: .title2)
    titleLabel.numberOfLines = 1
    titleLabel.lineBreakMode = .byTruncatingTail
    descriptionLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
    descriptionLabel.numberOfLines = 0
    descriptionLabel.lineBreakMode = .byWordWrapping
    customImageView.contentMode = .scaleAspectFit
  }

  private func addSubviews() {
    contentView.addSubview(container)
    container.addArrangedSubview(customImageView)
    container.addArrangedSubview(textContainer)
    textContainer.addArrangedSubview(titleLabel)
    textContainer.addArrangedSubview(descriptionLabel)
  }

  private let customImageView = UIImageView()
  private let textContainer = UIStackView()
  private let container = UIStackView()
  private let titleLabel = UILabel()
  private let descriptionLabel = UILabel()
}

private let spacing = CGFloat(8)
