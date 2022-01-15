import QtQuick
import QtQuick.Controls

AboutDialogForm {

    signal close()

    lblAppInfos {
        text: "nix" //applicationData !== null ? applicationData.getAppInfos() : "?"
    }

    lblIconInfos {
        onLinkActivated: Qt.openUrlExternally(link)
    }

    lblAppName {
        onLinkActivated: Qt.openUrlExternally(link)
    }

    lblGithubPage {
        onLinkActivated: Qt.openUrlExternally(link)
    }

    btnClose {
        onClicked: close()
    }
}
