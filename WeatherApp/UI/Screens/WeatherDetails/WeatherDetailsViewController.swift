//
//  WeatherDetailsViewController.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 15.04.22.
//

import UIKit


protocol WeatherDetailsViewControllerDelegateListener {

  func hourlyWeatherChanged()
}


protocol WeatherDetailsViewControllerDelegate: Listenable {

  var title: String { get }
  var timezone: TimeZone { get }
  var timestamps: [Int] { get }
  func getHourWeather(for timestamp: Int) -> HourWeather?

  func refetchDataIfNeeded()
  func closePressed()
}


class WeatherDetailsViewController: UIViewController, WeatherDetailsViewControllerDelegateListener {

  private let model: WeatherDetailsViewControllerDelegate
  private lazy var tableView = createTableView()
  private lazy var dataSource = DataSource(tableView: tableView, model: model)
  private var shouldScrollToNow = true

  init(model: WeatherDetailsViewControllerDelegate) {
    self.model = model

    super.init(nibName: nil, bundle: nil)

    navigationItem.title = model.title
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .close,
      target: self,
      action: #selector(closePressed)
    )
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    super.loadView()

    view.backgroundColor = .systemBackground

    tableView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(tableView)

    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.topAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    ])

    hourlyWeatherChanged()
    model.addListener(self)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    model.refetchDataIfNeeded()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    if shouldScrollToNow {
      shouldScrollToNow = false
      scrollToNow()
    }
  }

  // MARK: - WeatherDetailsViewControllerDelegateListener

  func hourlyWeatherChanged() {
    let existingItems = Set(dataSource.snapshot().itemIdentifiers)
    var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
    snapshot.appendSections([.single])
    snapshot.appendItems(model.timestamps)
    snapshot.reloadItems(model.timestamps.filter { existingItems.contains($0) })
    dataSource.apply(snapshot, animatingDifferences: false)
  }
}


// MARK: - Private
private extension WeatherDetailsViewController {

  func createTableView() -> UITableView {
    let tableView = UITableView(frame: .zero, style: .plain)
    tableView.allowsSelection = false
    return tableView
  }

  func scrollToNow() {
    let now = Date()
    if now.getMidnightTimestamp(in: model.timezone) == model.timestamps.first {
      let timestamp = now.getHourTimestamp(in: model.timezone)
      if let indexPath = dataSource.indexPath(for: timestamp) {
        tableView.scrollToRow(at: indexPath, at: .top, animated: false)
      }
    }
  }

  @objc
  func closePressed() {
    model.closePressed()
  }
}


// MARK: - Section
enum Section {
  case
  single
}


// MARK: - DataSource
private class DataSource: UITableViewDiffableDataSource<Section, Int> {

  init(tableView: UITableView, model: WeatherDetailsViewControllerDelegate) {
    tableView.register(Cell.self, forCellReuseIdentifier: Cell.reuseIdentifier)
    let dateFormatter = DateFormatterFactory.makeTime(timezone: model.timezone)
    
    super.init(tableView: tableView) { tableView, indexPath, itemIdentifier in
      let cell = tableView.dequeueReusableCell(withIdentifier: Cell.reuseIdentifier, for: indexPath) as! Cell
      cell.setup(
        with: model.getHourWeather(for: itemIdentifier),
        timestamp: itemIdentifier,
        dateFormatter: dateFormatter
      )
      return cell
    }
  }
}


// MARK: - Cell
private class Cell: UITableViewCell {

  static let reuseIdentifier = "Cell"

  private let timeLabel = UILabel()
  private let iconView = UIImageView()
  private let temperatureLabel = UILabel()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    timeLabel.font = UIFontConstants.hourTime
    timeLabel.setContentHuggingPriority(.required, for: .horizontal)
    timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    timeLabel.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(timeLabel)

    iconView.contentMode = .scaleAspectFit
    iconView.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(iconView)

    temperatureLabel.font = UIFontConstants.hourTemperature
    temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(temperatureLabel)

    let bottomConstraint = iconView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
    bottomConstraint.priority = .required - 1
    NSLayoutConstraint.activate([
      timeLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
      timeLabel.firstBaselineAnchor.constraint(equalTo: temperatureLabel.firstBaselineAnchor),

      iconView.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor, constant: LayoutConstants.spacing),
      iconView.widthAnchor.constraint(equalToConstant: LayoutConstants.cellIconSize.width),
      iconView.heightAnchor.constraint(equalToConstant: LayoutConstants.cellIconSize.height),
      iconView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
      bottomConstraint,

      temperatureLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: LayoutConstants.spacing),
      temperatureLabel.firstBaselineAnchor.constraint(equalTo: iconView.firstBaselineAnchor),
    ])
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setup(with hourWeather: HourWeather?, timestamp: Int, dateFormatter: DateFormatter) {
    timeLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: timestamp))
    if let hourWeather = hourWeather {
      iconView.image = hourWeather.weatherType.icon
      temperatureLabel.text = MeasurementFormatterConstants.temperature
        .string(temperatureC: hourWeather.temperatureC)
    } else {
      iconView.image = UIImage(systemName: "questionmark")!
      temperatureLabel.text = "--"
    }
  }
}
