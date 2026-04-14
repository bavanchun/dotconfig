import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../services"
import "../../theme"
import "../../widgets"

PanelWindow {
    visible: ShellState.sessionOpen
    color: "#66000000"
    exclusiveZone: 0
    implicitWidth: screen?.width ?? 900
    implicitHeight: screen?.height ?? 600

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    WlrLayershell.namespace: "quickshell:vchun-session"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    MouseArea {
        anchors.fill: parent
        onClicked: ShellState.sessionOpen = false
    }

    Rectangle {
        width: 460
        height: 170
        anchors.centerIn: parent
        radius: 8
        color: Theme.bg
        border.width: 1
        border.color: Theme.border

        RowLayout {
            anchors.centerIn: parent
            spacing: 10

            ActionButton { label: "Lock"; onPressed: Quickshell.execDetached(["loginctl", "lock-session"]) }
            ActionButton { label: "Logout"; onPressed: Quickshell.execDetached(["hyprctl", "dispatch", "exit"]) }
            ActionButton { label: "Reboot"; onPressed: Quickshell.execDetached(["systemctl", "reboot"]) }
            ActionButton { label: "Power"; onPressed: Quickshell.execDetached(["systemctl", "poweroff"]) }
        }
    }
}
