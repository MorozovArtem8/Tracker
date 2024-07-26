//  Created by Artem Morozov on 25.07.2024.


import UIKit

class TrackerViewController: UIViewController {
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    //MARK: UI Elements
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        return datePicker
    }()
    
    private lazy var emptyTrackerImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "emptyTracker")
        return imageView
    }()
    
    private lazy var emptyTrackerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "Что будем отслеживать?"
        return label
    }()
}


//MARK: Configure UI
private extension TrackerViewController {
    func configureUI() {
        view.backgroundColor = .white
        addNavigationItems()
        configureEmptyTrackerImageAndLabel()
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        self.datePicker.date = sender.date
    }
    
    func addNavigationItems() {
        let plusButton = UIBarButtonItem(image: UIImage(named: "TrackerPlus"), style: .plain, target: self, action: #selector(plusButtonTapped))
        plusButton.tintColor = UIColor("#1A1B22")
        self.navigationItem.leftBarButtonItem = plusButton
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    @objc func plusButtonTapped() {
        print("Plus button tapped")
    }
    
    func configureEmptyTrackerImageAndLabel() {
        emptyTrackerImage.translatesAutoresizingMaskIntoConstraints = false
        emptyTrackerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyTrackerImage)
        view.addSubview(emptyTrackerLabel)
        
        NSLayoutConstraint.activate([
            emptyTrackerImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emptyTrackerImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            emptyTrackerLabel.topAnchor.constraint(equalTo: emptyTrackerImage.bottomAnchor, constant: 8),
            emptyTrackerLabel.centerXAnchor.constraint(equalTo: emptyTrackerImage.centerXAnchor)
        ])
    }
}
