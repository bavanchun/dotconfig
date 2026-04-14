import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import "../../theme"

Rectangle {
    required property int workspaceId
    readonly property bool active: Hyprland.focusedWorkspace?.id === workspaceId

    Layout.preferredWidth: active ? 34 : 28
    Layout.preferredHeight: 28
    radius: 8
    color: active ? Theme.accent : Theme.bgAlt

    Text {
        anchors.centerIn: parent
        text: workspaceId
        color: parent.active ? Theme.accentText : Theme.fg
        font.family: "Inter"
        font.pixelSize: 12
        font.weight: Font.DemiBold
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Hyprland.dispatch(`workspace ${workspaceId}`)
    }
}
