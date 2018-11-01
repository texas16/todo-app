@testable import TodoApplication
import XCTest

final class ListPresenterTests: TestCase {
    // MARK: - Subject Under Test
    var presenter: ListPresenter!
    var viewMock: ListViewInputMock!
    
    // MARK: - Set Up
    override func setUp() {
        super.setUp()
        
        viewMock = ListViewInputMock()
        presenter = ListPresenterImpl(view: viewMock)
    }
    
    // MARK: - Tests
    
    func testPresenter_deleteItem_onSwipeToDelete() {
        // given
        let lists = [List(name: Identifier.generateUniqueIdentifier())]
        let response = ListDataFlow.ShowLists.Response(result: .success(lists))
        // when
        presenter.presentShowLists(response, identifier: nil)
        let sections = viewMock.invokedReloadTableParameters?.sections
        let cell = sections?[0].cells[0]
        let result = cell?.call(action: .swipeToDelete, cell: nil, indexPath: TestData.indexPath)
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(viewMock.invokedDeleteItemCount, 1)
    }
    
    func testPresenter_selectItem_onListTap() {
        // given
        let lists = [List(name: Identifier.generateUniqueIdentifier())]
        let response = ListDataFlow.ShowLists.Response(result: .success(lists))
        // when
        presenter.presentShowLists(response, identifier: nil)
        let sections = viewMock.invokedReloadTableParameters?.sections
        let cell = sections?[0].cells[0]
        let result = cell?.call(action: .tap, cell: nil, indexPath: TestData.indexPath)
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(viewMock.invokedSelectItemCount, 1)
    }
    
    func testPresenter_doesNotAllowSelectItem_onListTap_forEditingState() {
        // given
        let identifier = Identifier.generateUniqueIdentifier()
        let lists = [List(name: identifier)]
        let response = ListDataFlow.ShowLists.Response(result: .success(lists))
        // when
        presenter.presentShowLists(response, identifier: nil)
        presenter.presentListEditing(identifier)
        let sections = viewMock.invokedReloadTableParameters?.sections
        let cell = sections?[0].cells[0]
        let result = cell?.call(action: .tap, cell: nil, indexPath: TestData.indexPath)
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(viewMock.invokedSelectItemCount, 0)
    }
    
    func testPresentShowList_showError_forErrorResponse() {
        // given
        let response = ListDataFlow.ShowLists.Response(result: .failure(.internalError))
        // when
        presenter.presentShowLists(response, identifier: nil)
        // then
        XCTAssertEqual(viewMock.invokedShowAlertCount, 1)
        XCTAssertEqual(viewMock.invokedShowAlertParameters?.dialog.message, TestData.Text.internalError)
    }
    
    func testPresentShowList_updateTable_forSuccessfulResponse() {
        // given
        let lists = [List(name: Identifier.generateUniqueIdentifier())]
        let response = ListDataFlow.ShowLists.Response(result: .success(lists))
        // when
        presenter.presentShowLists(response, identifier: nil)
        // then
        XCTAssertEqual(viewMock.invokedReloadTableCount, 1)
    }
    
    func testPresentShowList_stopLoading_forSuccessfulResponse() {
        // given
        let lists = [List(name: Identifier.generateUniqueIdentifier())]
        let response = ListDataFlow.ShowLists.Response(result: .success(lists))
        // when
        presenter.presentShowLists(response, identifier: nil)
        // then
        XCTAssertEqual(viewMock.invokedStopActivityCount, 1)
    }
    
    func testPresentShowList_focusOnCell_forSuccessfulResponse_andNonnilIdentifier() {
        // given
        let identifier = Identifier.generateUniqueIdentifier()
        let lists = [List(name: Identifier.generateUniqueIdentifier())]
        let response = ListDataFlow.ShowLists.Response(result: .success(lists))
        // when
        presenter.presentShowLists(response, identifier: identifier)
        // then
        XCTAssertEqual(viewMock.invokedFocusOnCount, 1)
        XCTAssertEqual(viewMock.invokedFocusOnParameters?.identifier, identifier)
    }
    
    func testPresentError_showError_forInternalError() {
        testPresentError_showError_forText(error: .internalError, text: TestData.Text.internalError)
    }
    
    func testPresentError_showError_forCannotCreate() {
        testPresentError_showError_forText(error: .cannotCreate, text: TestData.Text.incorrectInput)
    }
    
    func testPresentError_showError_forCannotDelete() {
        testPresentError_showError_forText(error: .cannotDelete, text: TestData.Text.incorrectInput)
    }
    
    func testPresentError_showError_forCannotUpdate() {
        testPresentError_showError_forText(error: .cannotUpdate, text: TestData.Text.incorrectInput)
    }
    
    func testPresentError_showError_forCannotFetch() {
        testPresentError_showError_forText(error: .cannotFetch, text: TestData.Text.incorrectInput)
    }
    
    func testPresentLoading_startLoading() {
        // when
        presenter.presentLoading()
        // then
        XCTAssertEqual(viewMock.invokedStartActivityCount, 1)
    }
    
    func testPresentListEditing_focusOnCell() {
        // given
        let identifier = Identifier.generateUniqueIdentifier()
        // when
        presenter.presentListEditing(identifier)
        // then
        XCTAssertEqual(viewMock.invokedFocusOnCount, 1)
        XCTAssertEqual(viewMock.invokedFocusOnParameters?.identifier, identifier)
    }
    
    func testPresentListEditing_stopLoading() {
        // given
        let identifier = Identifier.generateUniqueIdentifier()
        // when
        presenter.presentListEditing(identifier)
        // then
        XCTAssertEqual(viewMock.invokedStopActivityCount, 1)
    }
    
    func testPresentListActions_showActionSheet() {
        // given
        let identifier = Identifier.generateUniqueIdentifier()
        let name = Identifier.generateUniqueIdentifier()
        // when
        presenter.presentListActions(identifier, name: name)
        // then
        XCTAssertEqual(viewMock.invokedShowActionSheetCount, 1)
        XCTAssertNotNil(viewMock.invokedShowActionSheetParameters)
    }
    
    func testPresentListActions_showEditing_whenEditingActionIsTapped() {
        // given
        let identifier = Identifier.generateUniqueIdentifier()
        let name = Identifier.generateUniqueIdentifier()
        // when
        presenter.presentListActions(identifier, name: name)
        let action = viewMock.invokedShowActionSheetParameters?.dialog.actions[safe: 0]
        action?.onTap?()
        // then
        XCTAssertEqual(viewMock.invokedShowEditingCount, 1)
    }
    
    func testPresentListActions_deleteItem_whenDeleteActionIsTapped() {
        // given
        let identifier = Identifier.generateUniqueIdentifier()
        let name = Identifier.generateUniqueIdentifier()
        // when
        presenter.presentListActions(identifier, name: name)
        let action = viewMock.invokedShowActionSheetParameters?.dialog.actions[safe: 1]
        action?.onTap?()
        // then
        XCTAssertEqual(viewMock.invokedDeleteItemCount, 1)
    }
    
    func testPresentListActions_openTasks_whenOpenTasksActionIsTapped() {
        // given
        let identifier = Identifier.generateUniqueIdentifier()
        let name = Identifier.generateUniqueIdentifier()
        // when
        presenter.presentListActions(identifier, name: name)
        let action = viewMock.invokedShowActionSheetParameters?.dialog.actions[safe: 2]
        action?.onTap?()
        // then
        XCTAssertEqual(viewMock.invokedOpenTasksCount, 1)
    }
    
    func testPresentListActions_buildDialog() {
        // given
        let identifier = Identifier.generateUniqueIdentifier()
        // when
        presenter.presentListActions(identifier, name: name)
        // then
        let dialog = viewMock.invokedShowActionSheetParameters?.dialog
        XCTAssertEqual(dialog?.actions.count, 4)
        XCTAssertEqual(dialog?.actions[safe: 0]?.title, TestData.Text.editList)
        XCTAssertEqual(dialog?.actions[safe: 1]?.title, TestData.Text.deleteList)
        XCTAssertEqual(dialog?.actions[safe: 2]?.title, TestData.Text.lookAtTasks)
        XCTAssertEqual(dialog?.actions[safe: 3]?.title, TestData.Text.cancel)
    }
    
    // MARK: - Private
    
    private func testPresentError_showError_forText(error: StorageError, text: String) {
        // when
        presenter.presentError(error)
        // then
        XCTAssertEqual(viewMock.invokedShowAlertCount, 1)
        
        let dialog = viewMock.invokedShowAlertParameters?.dialog
        XCTAssertEqual(dialog?.actions.count, 1)
        XCTAssertEqual(dialog?.actions[safe: 0]?.title, TestData.Text.ok)
        XCTAssertEqual(dialog?.message, text)
    }
    
}

extension ListPresenterTests {
    struct TestData {
        struct Text {
            static let incorrectInput = "Incorrect input in the database 🤔"
            static let internalError = "Internal error 😕 Please try again!"
            static let editList = "Edit list 📝"
            static let deleteList = "Delete list and all containing tasks 🗑"
            static let lookAtTasks = "Look at tasks ▶️"
            static let cancel = "Cancel"
            static let ok = "OK"
        }
        static let indexPath = IndexPath(row: 0, section: 0)
        
    }
}
