import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../services"
import "../../theme"
import "../../widgets"

PanelWindow {
    id: root
    visible: ShellState.controlCenterOpen
    color: "transparent"
    exclusiveZone: 0
    implicitWidth: 380
    implicitHeight: 430

    anchors {
        top: true
        right: true
    }

    margins {
        top: 72
        right: 12
    }

    WlrLayershell.namespace: "quickshell:vchun-control-center"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    PanelFrame {
        anchors.fill: parent
        title: "Control Center"

        GridLayout {
            columns: 2
            columnSpacing: 10
            rowSpacing: 10
            Layout.fillWidth: true

            ActionButton { label: "Network"; value: ShellData.networkText; onPressed: Quickshell.execDetached(["nm-connection-editor"]) }
            ActionButton { label: "Bluetooth"; value: "Open"; onPressed: Quickshell.execDetached(["blueman-manager"]) }
            ActionButton { label: "Audio"; value: `${ShellData.volume}%`; onPressed: Quickshell.execDetached(["pavucontrol"]) }
            ActionButton { label: "Brightness"; value: ShellData.backlightText; onPressed: Quickshell.execDetached(["bash", "-lc", "brightnessctl -e4 -n2 set 10%+"]) }
            ActionButton { label: "Power"; value: ShellData.powerProfileText; onPressed: Quickshell.execDetached(["bash", `${Quickshell.env("HOME")}/.config/waybar/scripts/power-profile-menu.sh`]) }
            ActionButton { label: "Night"; value: "Theme"; onPressed: Quickshell.execDetached(["bash", `${Quickshell.env("HOME")}/.config/hypr/scripts/toggle-theme.sh`]) }
        }

        Text {
            Layout.fillWidth: true
            text: ShellData.resourceText
            color: Theme.muted
            font.family: "Inter"
            font.pixelSize: 12
            wrapMode: Text.Wrap
        }
    }
}
