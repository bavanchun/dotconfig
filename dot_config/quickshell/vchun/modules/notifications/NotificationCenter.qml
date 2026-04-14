import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../services"
import "../../theme"
import "../../widgets"

PanelWindow {
    visible: ShellState.notificationsOpen
    color: "transparent"
    exclusiveZone: 0
    implicitWidth: 380
    implicitHeight: 260

    anchors {
        top: true
        right: true
    }

    margins {
        top: 72
        right: 12
    }

    WlrLayershell.namespace: "quickshell:vchun-notifications"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    PanelFrame {
        anchors.fill: parent
        title: "Notifications"

        Text {
            Layout.fillWidth: true
            text: `${ShellData.swayncText} unread notifications`
            color: Theme.fg
            font.family: "Inter"
            font.pixelSize: 18
            font.weight: Font.DemiBold
        }

        Text {
            Layout.fillWidth: true
            text: "SwayNC still owns delivery and history. This panel is the Quickshell bridge before replacing the daemon."
            color: Theme.muted
            font.family: "Inter"
            font.pixelSize: 12
            wrapMode: Text.Wrap
        }

        RowLayout {
            ActionButton { label: "Open"; onPressed: Quickshell.execDetached(["swaync-client", "-t", "-sw"]) }
            ActionButton { label: "DND"; onPressed: Quickshell.execDetached(["swaync-client", "-d", "-sw"]) }
            ActionButton { label: "Close"; onPressed: ShellState.notificationsOpen = false }
        }
    }
}
