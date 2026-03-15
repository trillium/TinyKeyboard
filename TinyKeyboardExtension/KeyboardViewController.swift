import UIKit

class KeyboardViewController: UIInputViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let inputView = self.inputView else { return }

        inputView.backgroundColor = .clear

        let heightConstraint = inputView.heightAnchor.constraint(equalToConstant: 1)
        heightConstraint.priority = .init(999)
        heightConstraint.isActive = true

        // Invisible spacer that gives the layout engine content to measure
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        inputView.addSubview(spacer)

        NSLayoutConstraint.activate([
            spacer.leadingAnchor.constraint(equalTo: inputView.leadingAnchor),
            spacer.trailingAnchor.constraint(equalTo: inputView.trailingAnchor),
            spacer.topAnchor.constraint(equalTo: inputView.topAnchor),
            spacer.bottomAnchor.constraint(equalTo: inputView.bottomAnchor),
        ])
    }
}
