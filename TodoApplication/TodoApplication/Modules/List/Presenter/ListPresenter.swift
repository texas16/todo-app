import Foundation

protocol ListPresenter: class {
    func presentShowLists(_ response: ListDataFlow.ShowLists.Response, identifier: Identifier?)
    func presentError(_ error: StorageError)
    func presentListActions(_ identifier: Identifier, name: String)
    func presentListEditing(_ identifier: Identifier)
}

final class ListPresenterImpl: ListPresenter {
    // MARK: - Dependencies
    private unowned let view: ListViewInput

    // MARK: - Init
    init(view: ListViewInput) {
        self.view = view
    }

    // MARK: - ListPresenter
    func presentShowLists(_ response: ListDataFlow.ShowLists.Response, identifier: Identifier?) {
        let viewModel: ListDataFlow.ShowLists.ViewModel
        switch response.result {
        case .success(let items):
            let resultItems = items.map {
                ListViewModel(
                    identifier: $0.identifier ?? "",
                    name: $0.name
                )
            }
            viewModel = ListDataFlow.ShowLists.ViewModel(state: .result(
                items: resultItems,
                listIdentifier: identifier
                )
            )
        case .failure(let error):
            viewModel = errorStateViewModel(error)
        }
        view.showItems(viewModel)
    }

    func presentError(_ error: StorageError) {
        let viewModel = errorStateViewModel(error)
        view.showItems(viewModel)
    }

    func presentListActions(_ identifier: Identifier, name: String) {
        let actions: [Dialog.Action] = [
            Dialog.Action(
                title: "Edit list 📝",
                style: .default) { [weak self] in
                    self?.view.showEditing(identifier)
            },
            Dialog.Action(
                title: "Delete list and all containing tasks 🗑",
                style: .default) { [weak self] in
                    self?.view.deleteItem(identifier)
            },
            Dialog.Action(
                title: "Look at tasks ▶️",
                style: .default) { [weak self] in
                    self?.view.openTasks(identifier, name: name)
            },
            Dialog.Action(
                title: "Cancel",
                style: .cancel,
                onTap: nil
            )
        ]
        let dialog = Dialog(actions: actions)
        view.showActionSheet(dialog)
    }

    func presentListEditing(_ identifier: Identifier) {
        view.showEditing(identifier)
    }

    // MARK: - Private
    func errorStateViewModel(_ error: StorageError) -> ListDataFlow.ShowLists.ViewModel {
        let dialogBuilder = DialogBuilder()
        let dialog = dialogBuilder.build(storageError: error)
        return ListDataFlow.ShowLists.ViewModel(state: .error(dialog: dialog))
    }
}
