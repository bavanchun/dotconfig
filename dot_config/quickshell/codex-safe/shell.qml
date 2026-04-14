//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Networking
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import Quickshell.Services.SystemTray
import Quickshell.Services.UPower
import Quickshell.Wayland

ShellRoot {
    id: root

    readonly property list<int> pinnedWorkspaces: [1, 2, 3, 4, 5]
    readonly property var clock: SystemClock {
        precision: SystemClock.Seconds
    }
    readonly property string mode: themeMode.loaded ? themeMode.text().trim() : "dark"
    readonly property bool light: mode === "light"
    readonly property color bg: light ? "#fdf8f9" : "#191112"
    readonly property color bgAlt: light ? "#f1dee2" : "#2a1b1e"
    readonly property color fg: light ? "#21191b" : "#f0dee0"
    readonly property color muted: light ? "#6f565d" : "#d9c2c6"
    readonly property color accent: "#c73e64"
    readonly property string timeText: Qt.locale().toString(clock.date, "HH:mm")
    readonly property string dateText: Qt.locale().toString(clock.date, "dd/MM")
    readonly property var player: Mpris.players.values.find(player => player.isPlaying) ?? Mpris.players.values[0]
    readonly property string mediaText: player ? truncate((player.trackTitle || player.identity || "Media"), 32) : "No media"
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property int volume: Math.round(((sink?.audio?.volume) ?? 0) * 100)
    readonly property var battery: UPower.displayDevice
    readonly property string batteryText: battery?.isLaptopBattery ? `${Math.round(battery.percentage * 100)}%` : "AC"
    readonly property string networkText: networkName.length > 0 ? networkName : (Networking.wifiEnabled ? "Wi-Fi" : "Net")

    property string windowTitle: "Desktop"
    property string networkName: ""

    function truncate(text, max) {
        if (!text)
            return "";
        return text.length > max ? text.slice(0, max - 1) + "..." : text;
    }

    function runProcess(process) {
        process.running = false;
        process.running = true;
    }

    FileView {
        id: themeMode
        path: `${Quickshell.env("HOME")}/.config/theme-mode`
        watchChanges: true
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root.runProcess(activeWindowProc);
            root.runProcess(networkProc);
        }
    }

    Process {
        id: activeWindowProc
        command: ["bash", "-lc", "hyprctl activewindow -j | jq -r 'if .title then .title else \"Desktop\" end' 2>/dev/null"]
        stdout: StdioCollector {
            id: activeWindowOutput
            onStreamFinished: root.windowTitle = root.truncate(activeWindowOutput.text.trim() || "Desktop", 48)
        }
    }

    Process {
        id: networkProc
        command: ["bash", "-lc", "nmcli -t -f TYPE,STATE,CONNECTION device status | awk -F: '$2==\"connected\" && $3!=\"\" {print $3; exit}'"]
        stdout: StdioCollector {
            id: networkOutput
            onStreamFinished: root.networkName = root.truncate(networkOutput.text.trim(), 22)
        }
    }

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

            WlrLayershell.namespace: "quickshell:codex-safe-bar"
            WlrLayershell.layer: WlrLayer.Top

            Rectangle {
                id: background
                anchors.fill: parent
                color: root.bg
                radius: 8
                border.width: 1
                border.color: root.light ? "#ead0d6" : "#3a272c"

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
                            model: root.pinnedWorkspaces

                            Rectangle {
                                required property int modelData
                                readonly property bool active: Hyprland.focusedWorkspace?.id === modelData

                                Layout.preferredWidth: active ? 34 : 28
                                Layout.preferredHeight: 28
                                radius: 8
                                color: active ? root.accent : root.bgAlt

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData
                                    color: parent.active ? "#ffffff" : root.fg
                                    font.family: "Inter"
                                    font.pixelSize: 12
                                    font.weight: Font.DemiBold
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: Hyprland.dispatch(`workspace ${modelData}`)
                                }
                            }
                        }

                        Chip {
                            label: "APP"
                            value: root.windowTitle
                            Layout.maximumWidth: 360
                        }

                        Chip {
                            label: "MPRIS"
                            value: root.mediaText
                            Layout.maximumWidth: 320

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: root.player ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: if (root.player && root.player.canTogglePlaying) root.player.togglePlaying()
                            }
                        }
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 8

                        Chip {
                            label: "NET"
                            value: root.networkText
                        }

                        Chip {
                            label: root.sink?.audio?.muted ? "MUTE" : "VOL"
                            value: `${root.volume}%`
                        }

                        Chip {
                            label: "BAT"
                            value: root.batteryText
                            visible: root.battery?.isLaptopBattery ?? false
                        }

                        Chip {
                            label: "TRAY"
                            value: `${SystemTray.items.values.length}`
                        }

                        Chip {
                            label: root.dateText
                            value: root.timeText
                        }
                    }
                }
            }
        }
    }

    component Chip: Rectangle {
        property string label: ""
        property string value: ""

        implicitHeight: 30
        implicitWidth: content.implicitWidth + 20
        radius: 8
        color: root.bgAlt

        RowLayout {
            id: content
            anchors.centerIn: parent
            spacing: 6

            Text {
                text: label
                color: root.muted
                font.family: "Inter"
                font.pixelSize: 10
                font.weight: Font.DemiBold
            }

            Text {
                text: value
                color: root.fg
                elide: Text.ElideRight
                font.family: "Inter"
                font.pixelSize: 12
                font.weight: Font.Medium
                Layout.maximumWidth: 280
            }
        }
    }
}
