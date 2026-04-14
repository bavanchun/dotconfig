import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../../services"
import "../../theme"
import "../../widgets"

PanelWindow {
    id: root
    visible: ShellState.wallpaperOpen
    color: "transparent"
    exclusiveZone: 0
    implicitWidth: 760
    implicitHeight: 560
    property var wallpapers: []

    anchors {
        top: true
    }

    margins {
        top: 96
    }

    WlrLayershell.namespace: "quickshell:vchun-wallpaper"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    onVisibleChanged: if (visible) refreshProc.running = true

    Process {
        id: refreshProc
        command: ["bash", "-lc", "find \"$HOME/Pictures/Wallpapers\" \"$HOME/Downloads/archdrawsalot_desktop_wallpapers\" -maxdepth 2 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) 2>/dev/null | head -60"]
        stdout: StdioCollector {
            id: wallpaperOutput
            onStreamFinished: root.wallpapers = wallpaperOutput.text.trim().length > 0 ? wallpaperOutput.text.trim().split("\n") : []
        }
    }

    PanelFrame {
        anchors.fill: parent
        title: "Wallpaper"

        GridView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            cellWidth: 170
            cellHeight: 118
            clip: true
            model: root.wallpapers

            delegate: Rectangle {
                required property string modelData
                width: 158
                height: 104
                radius: 8
                color: Theme.bgAlt
                border.width: 1
                border.color: Theme.border

                Image {
                    anchors.fill: parent
                    anchors.margins: 3
                    source: `file://${modelData}`
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    clip: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Quickshell.execDetached(["bash", `${Quickshell.env("HOME")}/.config/hypr/scripts/set-wallpaper.sh`, modelData]);
                        ShellState.wallpaperOpen = false;
                    }
                }
            }
        }
    }
}
