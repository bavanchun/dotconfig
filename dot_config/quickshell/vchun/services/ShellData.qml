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
    property string resourceText: "CPU --  RAM --  --C"
    property string backlightText: "--%"
    property string fcitxText: "--"
    property string powerProfileText: "--"
    property string swayncText: "0"

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
        interval: Config.statusIntervalMs
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            ShellData.runProcess(activeWindowProc);
            ShellData.runProcess(networkProc);
            ShellData.runProcess(backlightProc);
            ShellData.runProcess(fcitxProc);
            ShellData.runProcess(powerProfileProc);
            ShellData.runProcess(swayncProc);
        }
    }

    Timer {
        interval: Config.resourcesIntervalMs
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: ShellData.runProcess(resourcesProc)
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

    Process {
        id: resourcesProc
        command: ["bash", "-lc", "read _ u n s i rest < /proc/stat; t=$((u+n+s+i)); sleep 0.2; read _ u2 n2 s2 i2 rest < /proc/stat; t2=$((u2+n2+s2+i2)); dt=$((t2-t)); di=$((i2-i)); cpu=$((dt>0 ? (100*(dt-di)/dt) : 0)); mem=$(awk '/MemTotal/ {t=$2} /MemAvailable/ {a=$2} END {printf \"%.1fG\", (t-a)/1048576}' /proc/meminfo); temp=$(awk '{printf \"%dC\", $1/1000}' /sys/class/thermal/thermal_zone9/temp 2>/dev/null || printf -- \"--C\"); printf 'CPU %s%%  RAM %s  %s' \"$cpu\" \"$mem\" \"$temp\""]
        stdout: StdioCollector {
            id: resourcesOutput
            onStreamFinished: ShellData.resourceText = resourcesOutput.text.trim() || ShellData.resourceText
        }
    }

    Process {
        id: backlightProc
        command: ["bash", "-lc", "brightnessctl -m 2>/dev/null | awk -F, '{gsub(/%/,\"\",$4); print $4 \"%\"}'"]
        stdout: StdioCollector {
            id: backlightOutput
            onStreamFinished: ShellData.backlightText = backlightOutput.text.trim() || ShellData.backlightText
        }
    }

    Process {
        id: fcitxProc
        command: ["bash", "-lc", "fcitx5-remote -n 2>/dev/null | awk '{if ($0 == \"keyboard-us\") print \"EN\"; else if ($0 == \"\") print \"--\"; else print \"VI\"}'"]
        stdout: StdioCollector {
            id: fcitxOutput
            onStreamFinished: ShellData.fcitxText = fcitxOutput.text.trim() || "--"
        }
    }

    Process {
        id: powerProfileProc
        command: ["bash", "-lc", "powerprofilesctl get 2>/dev/null | awk '{if ($0 == \"performance\") print \"Perf\"; else if ($0 == \"balanced\") print \"Bal\"; else if ($0 != \"\") print \"Eco\"; else print \"--\"}'"]
        stdout: StdioCollector {
            id: powerProfileOutput
            onStreamFinished: ShellData.powerProfileText = powerProfileOutput.text.trim() || "--"
        }
    }

    Process {
        id: swayncProc
        command: ["bash", "-lc", "swaync-client --count 2>/dev/null || printf 0"]
        stdout: StdioCollector {
            id: swayncOutput
            onStreamFinished: ShellData.swayncText = swayncOutput.text.trim() || "0"
        }
    }
}
