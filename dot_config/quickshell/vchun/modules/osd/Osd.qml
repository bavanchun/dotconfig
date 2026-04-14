import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../services"
import "../../theme"

PanelWindow {
    visible: ShellState.osdOpen
    color: "transparent"
    exclusiveZone: 0
    implicitWidth: 220
    implicitHeight: 64

    anchors {
        bottom: true
    }

    margins {
        bottom: 120
    }

    WlrLayershell.namespace: "quickshell:vchun-osd"
    WlrLayershell.layer: WlrLayer.Overlay

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: Theme.bg
        border.width: 1
        border.color: Theme.border

        RowLayout {
            anchors.centerIn: parent
            spacing: 10

            Text { text: ShellState.osdLabel; color: Theme.muted; font.family: "Inter"; font.pixelSize: 12; font.weight: Font.DemiBold }
            Text { text: ShellState.osdValue; color: Theme.fg; font.family: "Inter"; font.pixelSize: 18; font.weight: Font.DemiBold }
        }
    }
}
