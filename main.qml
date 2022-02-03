import QtQuick
import QtQuick.Controls
import Qt.labs.settings
import PicoTemplateApp

ApplicationWindow {
    id: window
    width: 640
    height: 480
    visible: true
    title: qsTr("Pico Template App")

    property string currentFileName: qsTr("unknown.txt")
    property string currentDecodedFileName: ""
    property string currentDirectory: "."

    property int iconSize: 40
    property int defaultIconSize: 40
    property int minimalIconSize: 12

    function setFileName(fileUri, decodedFileUri) {
        currentFileName = fileUri
        currentDecodedFileName = decodedFileUri
    }

    function addToOutput(txt) {
        homePage.txtEditor.text += txt + "\n"
    }

    function addErrorMessage(msg) {
        addToOutput(msg)
    }

    function focusToEditor() {
        homePage.txtEditor.forceActiveFocus()
    }

    function processOpenFileCallback(fileName) {
        var content = applicationData.readFileContent(fileName)
        setFileName(fileName, null)
        homePage.txtEditor.text = content
    }

    function processSaveFileCallback(fileName) {
        var content = homePage.txtEditor.text
        setFileName(fileName, null)
        doSaveFile(currentFileName, content, true)
    }

    function doSaveFile(fileName, text, bForceSyncWrite) {
        if( !bForceSyncWrite && applicationData.isWASM && !applicationData.isUseLocalFileDialog )
        {
            applicationData.saveFileContentAsync(text, applicationData.getOnlyFileName(fileName))
        }
        else
        {
            var ok = applicationData.writeFileContent(fileName, text)
            if( !ok )
            {
                var msg= localiseText(qsTr("ERROR: Can not save file ")) + fileName
                addErrorMessage(msg)
            }
        }
    }

    function triggerSaveAsFile() {
        if( !settings.mobileUI )
        {
            fileDialog.openMode = false
            fileDialog.folder = "."
            fileDialog.nameFilters = ["*"]
            fileDialog.open()
        }
        else
        {
            stackView.pop()
            mobileFileDialog.pathsSDCard = applicationData.getSDCardPaths()
            mobileFileDialog.isStorageSupported = applicationData.isAndroid
            mobileFileDialog.isMobilePlatform = applicationData.isAndroid
            mobileFileDialog.isAdminModus = !applicationData.isAndroid
            mobileFileDialog.homePath = applicationData.homePath
            mobileFileDialog.setDirectory(currentDirectory)
            mobileFileDialog.setSaveAsModus(false)
            stackView.push(mobileFileDialog)
            mobileFileDialog.forceActiveFocus()
        }
    }

    function triggerOpenFile() {
        if( applicationData.isWASM && !applicationData.isUseLocalFileDialog )
        {
            applicationData.getOpenFileContentAsync("*.txt")
        }
        else if( !settings.mobileUI )
        {
            fileDialog.openMode = true
            fileDialog.folder = "."
            fileDialog.nameFilters = ["*"]
            fileDialog.open()
        }
        else
        {
            stackView.pop()
            mobileFileDialog.pathsSDCard = applicationData.getSDCardPaths() // or: ["c:\\tmp","c:\\"]
            mobileFileDialog.isStorageSupported = applicationData.isAndroid
            mobileFileDialog.isMobilePlatform = applicationData.isAndroid
            mobileFileDialog.isAdminModus = !applicationData.isAndroid
            mobileFileDialog.homePath = applicationData.homePath
            mobileFileDialog.setDirectory(currentDirectory)
            mobileFileDialog.setOpenModus()
            stackView.push(mobileFileDialog)
            mobileFileDialog.forceActiveFocus()
        }
    }

    function showSettingsDialog() {
        settingsDialog.chbUseToolBar.checked = settings.useToolBar
        settingsDialog.chbMobileUI.checked = settings.mobileUI
        stackView.push(settingsDialog)
    }

    function showSupportDialog() {
        stackView.push(supportDialog)
    }

    function isDialogOpen() {
        return stackView.currentItem === aboutDialog ||
               stackView.currentItem === mobileFileDialog ||
               stackView.currentItem === settingsDialog ||
               stackView.currentItem === supportDialog
    }

    function showInfoDialog(msg, title) {
        infoDialog.messageText = msg
        if( title !== undefined ) {
            infoDialog.title = title            
        }
        infoDialog.open()
    }

    function showThankYouDialog(supportLevel) {
        showInfoDialog(qsTr("Thank you for supporting the development of this application !"), qsTr("Thank you !"))
    }

    header: ToolBar {
        contentHeight: toolButton.implicitHeight

        ToolButton {
            id: toolButton
            //text: stackView.depth > 1 ? "\u25C0" : "\u2630"
            icon.source: stackView.depth > 1 ? "/images/back.svg" : "/images/menu_bars.svg"
            font.pixelSize: Qt.application.font.pixelSize * 1.6
            anchors.left: parent.left
            onClicked: {
                if (stackView.depth > 1) {
                    stackView.pop()
                } else {
                    drawer.open()
                }
            }
        }

        Label {
            text: stackView.currentItem.title
            anchors.centerIn: parent
        }

        ToolButton {
            id: menuButton
            //text: "\u22EE"
            icon.source: "/images/menu.svg"
            font.pixelSize: Qt.application.font.pixelSize * 2.0
            anchors.right: parent.right
            onClicked: menu.open()

            Menu {
                id: menu
                y: menuButton.height

                MenuItem {
                    text: qsTr("Open")
                    //icon.source: "/open.svg"
                    enabled: !isDialogOpen()
                    onTriggered: {
                        triggerOpenFile()
                    }
                }
                MenuItem {
                    text: qsTr("Save")
                    //icon.source: "/save.svg"
                    enabled: !isDialogOpen()
                    onTriggered: {
                        doSaveFile(currentFileName, homePage.txtEditor.text)
                    }
                }
                MenuItem {
                    text: qsTr("Save as")
                    //icon.source: "/saveas.svg"
                    enabled: !isDialogOpen()
                    onTriggered: {
                        triggerSaveAsFile()
                    }
                }
                MenuItem {
                    text: qsTr("Delete")
                    //icon.source: "/delete.svg"
                    enabled: !isDialogOpen()
                    onTriggered: {
                        stackView.pop()
                        mobileFileDialog.pathsSDCard = applicationData.getSDCardPaths()
                        mobileFileDialog.isStorageSupported = applicationData.isAndroid
                        mobileFileDialog.isMobilePlatform = applicationData.isAndroid
                        mobileFileDialog.isAdminModus = !applicationData.isAndroid
                        mobileFileDialog.homePath = applicationData.homePath
                        mobileFileDialog.setDirectory(currentDirectory)
                        mobileFileDialog.setDeleteModus()
                        stackView.push(mobileFileDialog)
                        mobileFileDialog.forceActiveFocus()
                    }
                }
                MenuSeparator {}
                MenuItem {
                    text: qsTr("Settings")
                    enabled: !isDialogOpen()
                    onTriggered: {
                        showSettingsDialog()
                    }
                }
                MenuSeparator {}
                MenuItem {
                    text: qsTr("Support")
                    enabled: !isDialogOpen()
                    onTriggered: {
                        showSupportDialog()
                    }
                }
                MenuSeparator {}
                MenuItem {
                    text: qsTr("About")
                    enabled: !isDialogOpen()
                    onTriggered: {
                        stackView.push(aboutDialog)
                    }
                }
                MenuSeparator {}
                MenuItem {
                    text: qsTr("Test")
                    onTriggered: {
                        //console.log(qmlTestId.test())
                        //console.log(supportLevel0)
                        //console.log(supportLevel0.identifier)
                        //console.log(supportLevel0.price)
                        //console.log(myStoreId)
                        showInfoDialog("hello", "world")
                    }
                }
                MenuSeparator {}
                MenuItem {
                    text: qsTr("Exit")
                    onTriggered: {
                        Qt.quit()
                    }
                }
            }
        }
    }

    ToolBar {
        id: toolBar
        //anchors.fill: parent
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        visible: settings.useToolBar
        height: settings.useToolBar ? flow.implicitHeight/*implicitHeight*/ : 0
        //width: flow.implicitWidth
/*
        onHeightChanged: {
            if( toolBar.height>iconSize+flow.spacing ) {
                if( iconSize>minimalIconSize ) {
                    iconSize -= 2
                }
            } else if ( toolBar.height<defaultIconSize ) {
                if( iconSize<defaultIconSize ) {
                    iconSize += 1
                }
            }
        }
*/
        Flow {
            id: flow
            anchors.fill: parent
            spacing: 5

            ToolButton {
                id: toolButtonOpen
                icon.source: "/images/open-folder-with-document.svg"
                enabled: !isDialogOpen()
                height: iconSize
                width: height
                //enabled: (stackView.currentItem === homePage) && !isDialogOpen()
                //text: "Open"
                onClicked: {
                    triggerOpenFile()
                }
            }
            ToolButton {
                id: toolButtonSave
                icon.source: "/images/floppy-disk.svg"
                enabled: !isDialogOpen()
                height: iconSize
                width: height
                //enabled: (stackView.currentItem === homePage) && !isDialogOpen()
                //text: "Save"
                onClicked: {
                    triggerSaveAsFile()
                }
            }
            ToolButton {
                id: toolButtonUndo
                icon.source: "/images/back-arrow.svg"
                enabled: !isDialogOpen()
                height: iconSize
                width: height
                //enabled: (stackView.currentItem === homePage) && !isDialogOpen()
                //text: "Undo"
                onClicked: {
                }
            }
            ToolButton {
                id: toolButtonRedo
                icon.source: "/images/redo-arrow.svg"
                enabled: !isDialogOpen()
                height: iconSize
                width: height
                //enabled: (stackView.currentItem === homePage) && !isDialogOpen()
                //text: "Redo"
                onClicked: {
                }
            }
            ToolButton {
                id: toolButtonSearch
                icon.source: "/images/search.svg"
                enabled: !isDialogOpen()
                height: iconSize
                width: height
                //enabled: (stackView.currentItem === homePage) && !isDialogOpen()
                //text: "Search"
                onClicked: {
                }
            }
            ToolButton {
                id: toolButtonReplace
                icon.source: "/images/replace.svg"
                enabled: !isDialogOpen()
                height: iconSize
                width: height
                //enabled: (stackView.currentItem === homePage) && !isDialogOpen()
                //text: "Replace"
                onClicked: {
                }
            }
            ToolButton {
                id: toolButtonPrevious
                icon.source: "/images/left-arrow.svg"
                enabled: !isDialogOpen()
                height: iconSize
                width: height
                //enabled: (stackView.currentItem === homePage) && !isDialogOpen()
                //text: "Previous"
                onClicked: {
                }
            }
            ToolButton {
                id: toolButtonNext
                icon.source: "/images/right-arrow.svg"
                enabled: !isDialogOpen()
                height: iconSize
                width: height
                //enabled: (stackView.currentItem === homePage) && !isDialogOpen()
                //text: "Next"
                onClicked: {
                }
            }
            ToolButton {
                id: toolButtonShare
                icon.source: "/images/share.svg"
                enabled: !isDialogOpen()
                height: iconSize
                width: height
                //enabled: (stackView.currentItem === homePage) && !isDialogOpen()
                //text: "Share"
                onClicked: {
                    var s = homePage.txtEditor.text
                    var ok = applicationData.shareSimpleText(s);
                }
            }
            ToolButton {
                id: toolButtonSettings
                icon.source: "/images/settings.svg"
                enabled: !isDialogOpen()
                height: iconSize
                width: height
                //enabled: (stackView.currentItem === homePage) && !isDialogOpen()
                //text: "Settings"
                onClicked: {
                    showSettingsDialog()
                }
            }
            ToolButton {
                id: toolButtonClose
                icon.source: "/images/close.svg"
                enabled: !isDialogOpen()
                height: iconSize
                width: height
                //enabled: (stackView.currentItem === homePage) && !isDialogOpen()
                //text: "Close"
                onClicked: {
                }
            }

        }
    }

    Drawer {
        id: drawer
        width: window.width * 0.66
        height: window.height

        Column {
            anchors.fill: parent

            ItemDelegate {
                text: qsTr("Page 1")
                width: parent.width
                onClicked: {
                    stackView.push("Page1Form.ui.qml")
                    drawer.close()
                }
            }
            ItemDelegate {
                text: qsTr("Page 2")
                width: parent.width
                onClicked: {
                    stackView.push("Page2Form.ui.qml")
                    drawer.close()
                }
            }
        }
    }

    StackView {
        id: stackView
        initialItem: homePage
        //anchors.fill: parent
        anchors.top: toolBar.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
    }

    HomeForm {
        id: homePage
    }

    SettingsDialog {
        id: settingsDialog
        visible: false
    }

    AboutDialog {
        id: aboutDialog
        visible: false
    }

    MobileFileDialog {
        id: mobileFileDialog

        visible: false
    }

    SupportDialog {
        id: supportDialog
        visible: false
    }

    Store {
        id: myStoreId
    }

    Dialog {
        id: infoDialog
        visible: false
        title: qsTr("Error")
        width: 300
        height: 200

        property alias messageText: messageId.text

        Flow {
            Label {
                id: messageId
                //text: "hello test !"
            }

            Button {
                text: "Close"

                onClicked: infoDialog.close()
            }
        }

        //standardButtons: StandardButton.Ok
        //buttons: Dialog.MessageDialog.Ok
        onAccepted: {
            console.log("Close error msg")
        }
    }

    Product {
        id: supportLevel0
        identifier: "support_level_0"
        store: myStoreId
        type: Product.Unlockable

        property bool purchasing: false

        onPurchaseSucceeded: {
            //showInfoDialog(qsTr("Purchase successfull."))
            settings.supportLevel = 0

            transaction.finalize()

            showThankYouDialog(settings.supportLevel)

            // Reset purchasing flag
            purchasing = false
        }

        onPurchaseFailed: {
            showInfoDialog(qsTr("Purchase not completed."))
            transaction.finalize()

            // Reset purchasing flag
            purchasing = false
        }

        onPurchaseRestored: {
            //showInfoDialog(qsTr("Purchase restored."))
            settings.supportLevel = 0

            transaction.finalize()

            // Reset purchasing flag
            purchasing = false
        }
    }

    Product {
        id: supportLevel1
        identifier: "support_level_1"
        store: myStoreId
        type: Product.Unlockable

        property bool purchasing: false

        onPurchaseSucceeded: {
            settings.supportLevel = 1

            transaction.finalize()

            showThankYouDialog(settings.supportLevel)

            // Reset purchasing flag
            purchasing = false
        }

        onPurchaseFailed: {
            showInfoDialog(qsTr("Purchase not completed."))
            transaction.finalize()

            // Reset purchasing flag
            purchasing = false
        }

        onPurchaseRestored: {
            settings.supportLevel = 1

            transaction.finalize()

            // Reset purchasing flag
            purchasing = false
        }
    }

    Product {
        id: supportLevel2
        identifier: "support_level_2"
        store: myStoreId
        type: Product.Unlockable

        property bool purchasing: false


        onPurchaseSucceeded: {
            settings.supportLevel = 2

            transaction.finalize()

            showThankYouDialog(settings.supportLevel)

            // Reset purchasing flag
            purchasing = false
        }

        onPurchaseFailed: {
            showInfoDialog(qsTr("Purchase not completed."))
            transaction.finalize()

            // Reset purchasing flag
            purchasing = false
        }

        onPurchaseRestored: {
            settings.supportLevel = 2

            transaction.finalize()

            // Reset purchasing flag
            purchasing = false
        }
    }

    PicoTemplateCode {
        id: qmlTestId
    }

    Settings {
        id: settings

        property int supportLevel: -1   // no support level at all

        property bool useToolBar: true
        property bool mobileUI: false // applicationData.isMobileUI
    }

    Connections {
        target: mobileFileDialog

        //onRejected: stackView.pop()       // for Qt 5.12.xx
        function onRejected() {
            //addToOutput("mobileFileDialog Rejected")
            stackView.pop()
            focusToEditor()
        }
        function onAccepted() {
            //addToOutput("mobileFileDialog Accepted")
            currentDirectory = mobileFileDialog.lblDirectoryName.text
            stackView.pop()
            focusToEditor()
        }

        function onSaveSelectedFile(fileName) {
            processSaveFileCallback(fileName)
        }
        function onOpenSelectedFile(fileName) {
            //addToOutput("openSelectedFile="+fileName)
            processOpenFileCallback(fileName)
        }
        function onDeleteSelectedFile(fileName) {
            var ok = applicationData.deleteFile(fileName)
            if( !ok ) {
                var msg= localiseText(qsTr("ERROR: Can not delete file ")) + fileName
                addErrorMessage(msg)
            }
        }

        function onStorageOpenFile() {
            //console.log("storage open")
            //addToOutput("storage open")
            storageAccess.openFile()
        }
        function onStorageCreateFile(fileNane) {
            //console.log("storage create file "+fileNane)
            //addToOutput("storage create file "+fileNane)
            setFileName(fileName, null)
            storageAccess.createFile(fileNane)
        }
    }

    Connections {
        target: aboutDialog

        function onClose() {
            stackView.pop()
        }
    }

    Connections {
        target: settingsDialog

        function onAccepted() {
            // TODO: update settings
            settings.useToolBar = settingsDialog.chbUseToolBar.checked
            settings.mobileUI = settingsDialog.chbMobileUI.checked

            stackView.pop()
        }
        function onRejected() {
            stackView.pop()
        }
        function onRestoreDefaultSettings() {
            // TODO: restore default settings
        }
    }

    Connections {
        target: applicationData

        // used for WASM platform:
        function onReceiveOpenFileContent(fileName, fileContent) {
            setFileName(fileName, null)
            homePage.txtEditor.text = fileContent
        }
        /*
        function receiveOpenFileContent(fileName, fileContent) {
            setFileName(fileName, null)
            homePage.txtEditor.text = fileContent
        }
        */
        function onSendErrorText(msg) {
            homePage.txtEditor.text += "\n" + msg
        }
    }

    Connections {
        target: storageAccess

        function onOpenFileContentReceived(fileUri, decodedFileUri, fileContent) {
            //console.log("onOpenFileContentReceived")
            //addToOutput("onOpenFileContentReceived")
            homePage.txtEditor.text = fileContent
            setFileName(fileUri, decodedFileUri)
            stackView.pop()
        }
        function onOpenFileCanceled() {
            //console.log("onOpenFileCanceled")
            //addToOutput("onOpenFileCanceled")
            stackView.pop()
        }
        function onOpenFileError(message) {
            homePage.txtEditor.text = message
            //addToOutput("onOpenFileError: "+message)
            stackView.pop()
        }
        function onCreateFileReceived(fileUri, decodedFileUri) {
            //console.log("create file received "+fileUri+" decoded="+decodedFileUri)
            //addToOutput("create file received "+fileUri+" decoded="+decodedFileUri)
            setFileName(fileUri, decodedFileUri)
        }
    }
}
