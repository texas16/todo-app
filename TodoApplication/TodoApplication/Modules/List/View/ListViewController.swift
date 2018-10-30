import UIKit

final class ListViewController: UIViewController {

    // MARK: - Dependencies
    var interactor: ListInteractor?
    var router: ListRouter?
    var tableDirector: ListViewTableDirector?

    // MARK: - State

    private var state: ListDataFlow.ViewControllerState = .loading {
        didSet {
            switch state {
            case .loading:
                startActivity()
                interactor?.fetchItems()
            case .error(let dialog):
                stopActivity()
                showAlert(dialog)
            case .result(let items, let listIdentifier):
                stopActivity()
                tableDirector?.items = items
                if let listIdentifier = listIdentifier {
                    let request = ListDataFlow.OpenListEditing.Request(identifier: listIdentifier)
                    interactor?.openListEditing(request: request)
                }
            case .editing(let listIdentifier):
                stopActivity()
                tableDirector?.focusOnCell(listIdentifier)
            }
        }
    }

    private let keyboardObserver: KeyboardObserver = KeyboardObserverImpl()
    private var activityDisplayable: ActivityDisplayable?

    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableDirector?.setup(with: tableView)
        }
    }
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! {
        didSet {
            activityDisplayable = ActivityDisplayableImpl(
                activityIndicatorView: activityIndicator
            )
        }
    }

    // MARK: - Private views
    private var addListButton: UIBarButtonItem?

    // MARK: - ViewController life-cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        state = .loading

        tableDirector?.onListTap = { [weak self] viewModel in
            self?.onListTap(viewModel)
        }
        tableDirector?.onCellTextDidEndEditing = { [weak self] viewModel in
            let request = ListDataFlow.UpdateList.Request(
                identifier: viewModel.identifier,
                name: viewModel.name
            )
            self?.interactor?.updateItem(request: request)
        }
        tableDirector?.onDeleteTap = { [weak self] listIdentifier in
            let request = ListDataFlow.DeleteList.Request(identifier: listIdentifier)
            self?.interactor?.deleteItem(request: request)
        }

        keyboardObserver.onKeyboardWillShown = { [weak self] frame in
            self?.tableViewBottomConstraint.constant = frame.height
        }
        keyboardObserver.onKeyboardWillHide = { [weak self] in
            self?.tableViewBottomConstraint.constant = 0
        }

        addListButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(onAddListTap)
        )
        addListButton?.qaAccessibilityIdentifier = ListDataFlow.AccessibilityIdentifiers.createListButton
        navigationItem.rightBarButtonItem = addListButton
    }

    // MARK: - Private

    private func onListTap(_ viewModel: ListViewModel) {
        switch state {
        case .editing:
            break
        default:
            let request = ListDataFlow.OpenListActions.Request(
                identifier: viewModel.identifier,
                name: viewModel.name
            )
            interactor?.openListActions(request: request)
        }
    }

    @objc private func onAddListTap() {
        let request = ListDataFlow.CreateList.Request(name: "")
        interactor?.createItem(request: request)
    }

    // MARK: - ActivityDisplayable

    func startActivity() {
        activityDisplayable?.startActivity()
    }

    func stopActivity() {
        activityDisplayable?.stopActivity()
    }
}

extension ListViewController: ListViewInput {
    func showEditing(_ identifier: Identifier) {
        self.state = .editing(listIdentifier: identifier)
    }

    func deleteItem(_ identifier: Identifier) {
        let request = ListDataFlow.DeleteList.Request(identifier: identifier)
        interactor?.deleteItem(request: request)
    }

    func openTasks(_ identifier: Identifier, name: String) {
        router?.openTasks(listIdentifier: identifier, name: name)
    }

    func showItems(_ viewModel: ListDataFlow.ShowLists.ViewModel) {
        self.state = viewModel.state
    }
}
