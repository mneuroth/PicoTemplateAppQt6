import QtQuick

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

    TextEdit {
        id: textEdit

        text: "hello world"
    }
}
