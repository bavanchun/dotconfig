import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../services"
import "../../theme"
import "../../widgets"

PanelWindow {
    visible: ShellState.calendarOpen
    color: "transparent"
    exclusiveZone: 0
    implicitWidth: 360
    implicitHeight: 260

    anchors {
        top: true
        right: true
    }

    margins {
        top: 72
        right: 12
    }

    WlrLayershell.namespace: "quickshell:vchun-calendar-media"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    PanelFrame {
        anchors.fill: parent
        title: Qt.locale().toString(ShellData.clock.date, "dddd, dd/MM/yyyy")

        Text {
            Layout.fillWidth: true
            text: ShellData.timeText
            color: Theme.fg
            font.family: "Inter"
            font.pixelSize: 34
            font.weight: Font.DemiBold
        }

        Text {
            Layout.fillWidth: true
            text: ShellData.mediaText
            color: Theme.muted
            font.family: "Inter"
            font.pixelSize: 13
            wrapMode: Text.Wrap
        }

        RowLayout {
            ActionButton { label: "Prev"; onPressed: if (ShellData.player) ShellData.player.previous() }
            ActionButton { label: "Play"; onPressed: if (ShellData.player) ShellData.player.togglePlaying() }
            ActionButton { label: "Next"; onPressed: if (ShellData.player) ShellData.player.next() }
        }
    }
}
