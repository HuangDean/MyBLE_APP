import UIKit

protocol UIToolbarPickerViewDelegate: class {
    func didTapDone(pickerView: UIPickerView)
    func didTapCancel()
}

class UIToolbarPickerView: UIPickerView {

    open private(set) var toolbar: UIToolbar?
    open weak var toolbarDelegate: UIToolbarPickerViewDelegate?
    open weak var pickerView: UIPickerView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    private func commonInit() {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 55))
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = .black
        toolBar.sizeToFit()

        let doneButton = UIBarButtonItem(title: NSLocalizedString("submit", comment: ""), style: .plain, target: self, action: #selector(self.doneTapped))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: NSLocalizedString("cancel", comment: ""), style: .plain, target: self, action: #selector(self.cancelTapped))

        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true

        self.toolbar = toolBar
    }

    @objc func doneTapped() {
        self.toolbarDelegate?.didTapDone(pickerView: self)
    }

    @objc func cancelTapped() {
        self.toolbarDelegate?.didTapCancel()
    }
}
