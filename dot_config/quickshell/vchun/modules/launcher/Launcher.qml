import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../services"
import "../../theme"
import "../../widgets"

PanelWindow {
    id: root
    visible: ShellState.launcherOpen
    color: "transparent"
    exclusiveZone: 0
    implicitWidth: 620
    implicitHeight: 520
    property var filteredApps: DesktopEntries.applications.values
        .filter(app => !app.noDisplay && (query.text.length === 0 || app.name.toLowerCase().includes(query.text.toLowerCase())))
        .slice(0, 9)

    anchors {
        top: true
    }

    margins {
        top: 110
    }

    WlrLayershell.namespace: "quickshell:vchun-launcher"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    PanelFrame {
        anchors.fill: parent
        title: "Launcher"

        TextInput {
            id: query
            Layout.fillWidth: true
            height: 38
            focus: root.visible
            color: Theme.fg
            selectedTextColor: Theme.accentText
            selectionColor: Theme.accent
            font.family: "Inter"
            font.pixelSize: 18
            text: ""
            Keys.onEscapePressed: ShellState.launcherOpen = false
            Keys.onReturnPressed: {
                if (filteredApps.length > 0) {
                    filteredApps[0].execute();
                    ShellState.launcherOpen = false;
                } else if (text.trim().length > 0) {
                    Quickshell.execDetached(["bash", "-lc", text.trim()]);
                    ShellState.launcherOpen = false;
                }
            }
        }

        Repeater {
            model: root.filteredApps
            delegate: ActionButton {
                required property var modelData
                Layout.fillWidth: true
                label: modelData.name
                value: modelData.comment
                onPressed: {
                    modelData.execute();
                    ShellState.launcherOpen = false;
                }
            }
        }
    }
}
