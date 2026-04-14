pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import Quickshell.Services.SystemTray
import Quickshell.Services.UPower
import "../config"

Singleton {
    readonly property list<int> pinnedWorkspaces: Config.workspaces
    readonly property var clock: SystemClock {
        precision: SystemClock.Seconds
    }
    readonly property string timeText: Qt.locale().toString(clock.date, "HH:mm")
    readonly property string dateText: Qt.locale().toString(clock.date, "dd/MM")
    readonly property var player: Mpris.players.values.find(player => player.isPlaying) ?? Mpris.players.values[0]
    readonly property string mediaText: player ? truncate((player.trackTitle || player.identity || "Media"), Config.mediaMaxChars) : "No media"
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property int volume: Math.round(((sink?.audio?.volume) ?? 0) * 100)
    readonly property var battery: UPower.displayDevice
    readonly property string batteryText: battery?.isLaptopBattery ? `${Math.round(battery.percentage * 100)}%` : "AC"
    readonly property string networkText: networkName.length > 0 ? networkName : (Networking.wifiEnabled ? "Wi-Fi" : "Net")
    readonly property int trayCount: SystemTray.items.values.length

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

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            ShellData.runProcess(activeWindowProc);
            ShellData.runProcess(networkProc);
        }
    }

    Process {
        id: activeWindowProc
        command: ["bash", "-lc", "hyprctl activewindow -j | jq -r 'if .title then .title else \"Desktop\" end' 2>/dev/null"]
        stdout: StdioCollector {
            id: activeWindowOutput
            onStreamFinished: ShellData.windowTitle = ShellData.truncate(activeWindowOutput.text.trim() || "Desktop", Config.windowTitleMaxChars)
        }
    }

    Process {
        id: networkProc
        command: ["bash", "-lc", "nmcli -t -f TYPE,STATE,CONNECTION device status | awk -F: '$2==\"connected\" && $3!=\"\" {print $3; exit}'"]
        stdout: StdioCollector {
            id: networkOutput
            onStreamFinished: ShellData.networkName = ShellData.truncate(networkOutput.text.trim(), Config.networkNameMaxChars)
        }
    }
}
