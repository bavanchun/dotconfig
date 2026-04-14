import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../config"
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
        implicitHeight: Config.barHeight
        exclusiveZone: Config.barExclusiveZone

        anchors {
            top: true
            left: true
            right: true
        }

        margins {
            top: Config.barMarginTop
            left: Config.barMarginSide
            right: Config.barMarginSide
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
                anchors.leftMargin: Config.barPaddingSide
                anchors.rightMargin: Config.barPaddingSide
                spacing: Config.barSpacing

                RowLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: Config.groupSpacing

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
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onClicked: event => {
                                if (event.button === Qt.RightButton)
                                    ShellState.toggleCalendar();
                                else if (ShellData.player && ShellData.player.canTogglePlaying)
                                    ShellData.player.togglePlaying();
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.alignment: Qt.AlignVCenter
                    spacing: Config.groupSpacing

                    Chip {
                        label: "SYS"
                        value: ShellData.resourceText
                    }

                    Chip {
                        label: "BRT"
                        value: ShellData.backlightText

                        MouseArea {
                            anchors.fill: parent
                            onWheel: event => {
                                Quickshell.execDetached(["brightnessctl", "-e4", "-n2", "set", event.angleDelta.y > 0 ? "5%+" : "5%-"]);
                                ShellState.showOsd("BRT", ShellData.backlightText);
                            }
                        }
                    }

                    Chip {
                        label: "NET"
                        value: ShellData.networkText

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Quickshell.execDetached(["nm-connection-editor"])
                        }
                    }

                    Chip {
                        label: ShellData.sink?.audio?.muted ? "MUTE" : "VOL"
                        value: `${ShellData.volume}%`

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Quickshell.execDetached(["pavucontrol"])
                            onWheel: event => {
                                Quickshell.execDetached(["bash", "-lc", event.angleDelta.y > 0 ? "wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+" : "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"]);
                                ShellState.showOsd("VOL", `${ShellData.volume}%`);
                            }
                        }
                    }

                    Chip {
                        label: "BT"
                        value: "󰂯"

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Quickshell.execDetached(["blueman-manager"])
                        }
                    }

                    Chip {
                        label: "PWR"
                        value: ShellData.powerProfileText

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Quickshell.execDetached(["bash", `${Quickshell.env("HOME")}/.config/waybar/scripts/power-profile-menu.sh`])
                        }
                    }

                    Chip {
                        label: "IME"
                        value: ShellData.fcitxText

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Quickshell.execDetached(["fcitx5-remote", "-t"])
                        }
                    }

                    Chip {
                        label: "NOTI"
                        value: ShellData.swayncText

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onClicked: event => {
                                if (event.button === Qt.RightButton)
                                    Quickshell.execDetached(["swaync-client", "-d", "-sw"]);
                                else
                                    ShellState.toggleNotifications();
                            }
                        }
                    }

                    Chip {
                        label: "BAT"
                        value: ShellData.batteryText
                        visible: ShellData.battery?.isLaptopBattery ?? false
                    }

                    TrayIcons {}

                    Chip {
                        label: ShellData.dateText
                        value: ShellData.timeText

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onClicked: event => {
                                if (event.button === Qt.RightButton)
                                    ShellState.toggleSession();
                                else
                                    ShellState.toggleControlCenter();
                            }
                        }
                    }
                }
            }
        }
    }
}
