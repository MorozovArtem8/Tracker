//  Created by Artem Morozov on 14.09.2024.


import UIKit

final class CreateCategoryScreenViewController: UIViewController {
    
    private lazy var nameCategoryTextField = PaddedTextField()
    private let addCategoryButton: UIButton = UIButton()
    private weak var delegate: CreateNewCategoryDelegate?
    
    init(delegate: CreateNewCategoryDelegate) {
        self.delegate = delegate
        super .init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        self.hideKeyboardWhenTappedAround()
    }
}

//MARK: UITextFieldDelegate func

extension CreateCategoryScreenViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.location == 0 && string == " " {
            return false
        }
        
        return true
    }
}

//MARK: Configure UI

private extension CreateCategoryScreenViewController {
    func configureUI() {
        view.backgroundColor = .white
        self.title = "Новая категория"
        configureTextField()
        configureAddCategoryButton()
    }
    
    func configureTextField() {
        nameCategoryTextField.delegate = self
        nameCategoryTextField.translatesAutoresizingMaskIntoConstraints = false
        nameCategoryTextField.placeholder = "Введите название категории"
        nameCategoryTextField.textColor = .black
        nameCategoryTextField.backgroundColor = UIColor("#E6E8EB", alpha: 0.3)
        nameCategoryTextField.textAlignment = .left
        nameCategoryTextField.layer.cornerRadius = 16
        nameCategoryTextField.clipsToBounds = true
        nameCategoryTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        view.addSubview(nameCategoryTextField)
        
        NSLayoutConstraint.activate([
            nameCategoryTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            nameCategoryTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameCategoryTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameCategoryTextField.heightAnchor.constraint(equalToConstant: 75)
            
        ])
    }
    
    @objc private func textFieldDidChange() {
        if nameCategoryTextField.text?.isEmpty ?? true {
            addCategoryButton.backgroundColor = UIColor("#AEAFB4")
            addCategoryButton.isEnabled = false
        } else {
            addCategoryButton.backgroundColor = UIColor("#1A1B22")
            addCategoryButton.isEnabled = true
        }
    }
    
    func configureAddCategoryButton() {
        addCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        addCategoryButton.backgroundColor = UIColor("#AEAFB4")
        addCategoryButton.isEnabled = false
        addCategoryButton.setTitle("Готово", for: .normal)
        addCategoryButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        addCategoryButton.layer.cornerRadius = 16
        addCategoryButton.clipsToBounds = true
        addCategoryButton.addTarget(self, action: #selector(addCategoryButtonButtonTapped), for: .touchUpInside)
        view.addSubview(addCategoryButton)
        
        NSLayoutConstraint.activate([
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc func addCategoryButtonButtonTapped() {
        guard let text = nameCategoryTextField.text else {return}
        dismiss(animated: true, completion: nil)
        delegate?.createNewCategory(categoryHeader: text)
    }
}

