import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../services"
import "../../theme"
import "../../widgets"

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: bar
        required property ShellScreen modelData

        screen: modelData
        color: "transparent"
        implicitHeight: 54
        exclusiveZone: 60

        anchors {
            top: true
            left: true
            right: true
        }

        margins {
            top: 6
            left: 10
            right: 10
        }

        WlrLayershell.namespace: "quickshell:vchun-bar"
        WlrLayershell.layer: WlrLayer.Top

        Rectangle {
            id: background
            anchors.fill: parent
            color: Theme.bg
            radius: 8
            border.width: 1
            border.color: Theme.border

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 8

                    Repeater {
                        model: ShellData.pinnedWorkspaces

                        WorkspaceButton {
                            required property int modelData
                            workspaceId: modelData
                        }
                    }

                    Chip {
                        label: "APP"
                        value: ShellData.windowTitle
                        Layout.maximumWidth: 360
                    }

                    Chip {
                        label: "MPRIS"
                        value: ShellData.mediaText
                        Layout.maximumWidth: 320

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: ShellData.player ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: if (ShellData.player && ShellData.player.canTogglePlaying) ShellData.player.togglePlaying()
                        }
                    }
                }

                RowLayout {
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 8

                    Chip {
                        label: "NET"
                        value: ShellData.networkText
                    }

                    Chip {
                        label: ShellData.sink?.audio?.muted ? "MUTE" : "VOL"
                        value: `${ShellData.volume}%`
                    }

                    Chip {
                        label: "BAT"
                        value: ShellData.batteryText
                        visible: ShellData.battery?.isLaptopBattery ?? false
                    }

                    Chip {
                        label: "TRAY"
                        value: `${ShellData.trayCount}`
                    }

                    Chip {
                        label: ShellData.dateText
                        value: ShellData.timeText
                    }
                }
            }
        }
    }
}
