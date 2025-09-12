//
//  placeDataViewController.swift
//  NavioiOS
//
//  Created by 송영민 on 9/11/25.
//
// PlaceDetailViewController.swift
import UIKit
import GooglePlaces

final class PlaceDetailViewController: UIViewController {
  private let placeName: String

  private let stack = UIStackView()
  private let nameLabel = UILabel()
  private let coordLabel = UILabel()
  private let phoneLabel = UILabel()
  private let addrLabel = UILabel()
  private let summaryLabel = UILabel()
  private let imageView = UIImageView()
  private let attributionLabel = UILabel()

  init(placeName: String) {
    self.placeName = placeName
    super.init(nibName: nil, bundle: nil)
  }
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "상세"
    view.backgroundColor = .systemBackground
    setupUI()
    fetchDetail()
  }

  private func setupUI() {
    summaryLabel.numberOfLines = 0
    addrLabel.numberOfLines = 0
    nameLabel.font = .boldSystemFont(ofSize: 20)
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    attributionLabel.numberOfLines = 0

    stack.axis = .vertical
    stack.spacing = 8
    stack.translatesAutoresizingMaskIntoConstraints = false
    [nameLabel, coordLabel, phoneLabel, addrLabel, summaryLabel, imageView, attributionLabel].forEach { stack.addArrangedSubview($0) }

    view.addSubview(stack)
    NSLayoutConstraint.activate([
      stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
      stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      imageView.heightAnchor.constraint(equalToConstant: 220)
    ])
  }

  private func fetchDetail() {
    let client = GMSPlacesClient.shared()
    let token = GMSAutocompleteSessionToken()

    let filter = GMSAutocompleteFilter()
    filter.types = ["establishment"]
    filter.countries = ["KR"]

    client.findAutocompletePredictions(
      fromQuery: placeName,
      filter: filter,
      sessionToken: token
    ) { [weak self] preds, err in
      if let err = err { print("autocomplete error:", err) }
      guard let pid = preds?.first?.placeID else {
        DispatchQueue.main.async { self?.nameLabel.text = "검색 결과 없음" }
        return
      }
      self?.fetchPlaceDetail(placeID: pid, client: client, token: token)
    }
  }

  private func fetchPlaceDetail(placeID: String, client: GMSPlacesClient, token: GMSAutocompleteSessionToken) {
    let fields: GMSPlaceField = [.name, .coordinate, .formattedAddress, .phoneNumber, .editorialSummary, .photos]
    client.fetchPlace(fromPlaceID: placeID, placeFields: fields, sessionToken: token) { [weak self] place, error in
      if let error = error { print("fetchPlace error:", error) }
      guard let self, let p = place else { return }

      DispatchQueue.main.async {
        self.nameLabel.text = "이름: \(p.name ?? "-")"
        self.coordLabel.text = String(format: "좌표: %.6f, %.6f", p.coordinate.latitude, p.coordinate.longitude)
        self.phoneLabel.text = "전화: \(p.phoneNumber ?? "-")"
        self.addrLabel.text = "주소: \(p.formattedAddress ?? "-")"
        self.summaryLabel.text = "설명: \(p.editorialSummary ?? "-")" // SDK에 따라 String?일 수 있음

        if let meta = p.photos?.first {
          client.loadPlacePhoto(meta, constrainedTo: CGSize(width: 800, height: 600), scale: UIScreen.main.scale) { [weak self] image, err in
            if let err = err { print("loadPhoto error:", err) }
            DispatchQueue.main.async {
              self?.imageView.image = image
              self?.attributionLabel.attributedText = meta.attributions
            }
          }
        } else {
          self.imageView.image = nil
          self.attributionLabel.text = ""
        }
      }
    }
  }
}
