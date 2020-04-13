import UIKit

/// Contains a text field.
///
final class TextFieldTableViewCell: UITableViewCell {
    struct ViewModel {
        let text: String?
        let placeholder: String?
        let onTextChange: ((_ text: String?) -> Void)?
        let onTextDidBeginEditing: (() -> Void)?
    }

    @IBOutlet weak var textField: UITextField!

    private var onTextChange: ((_ text: String?) -> Void)?
    private var onTextDidBeginEditing: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        configureTextField()
        applyDefaultBackgroundStyle()
        selectionStyle = .none
    }

    func configure(viewModel: ViewModel) {
        onTextChange = viewModel.onTextChange
        onTextDidBeginEditing = viewModel.onTextDidBeginEditing

        textField.text = viewModel.text
        textField.placeholder = viewModel.placeholder
        textField.borderStyle = .none
        textField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        textField.addTarget(self, action: #selector(textFieldDidBegin(textField:)), for: .editingDidBegin)
    }
}

private extension TextFieldTableViewCell {
    func configureTextField() {
        textField.clearButtonMode = .whileEditing
        textField.applyHeadlineStyle()
        textField.delegate = self
    }
}

private extension TextFieldTableViewCell {
    @objc func textFieldDidChange(textField: UITextField) {
        onTextChange?(textField.text)
    }

    @objc func textFieldDidBegin(textField: UITextField) {
        onTextDidBeginEditing?()
    }
}

extension TextFieldTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
