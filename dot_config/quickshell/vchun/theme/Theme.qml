pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    readonly property string mode: themeMode.loaded ? themeMode.text().trim() : "dark"
    readonly property bool light: mode === "light"

    readonly property color bg: light ? "#fdf8f9" : "#191112"
    readonly property color bgAlt: light ? "#f1dee2" : "#2a1b1e"
    readonly property color fg: light ? "#21191b" : "#f0dee0"
    readonly property color muted: light ? "#6f565d" : "#d9c2c6"
    readonly property color border: light ? "#ead0d6" : "#3a272c"
    readonly property color accent: "#c73e64"
    readonly property color accentText: "#ffffff"

    FileView {
        id: themeMode
        path: `${Quickshell.env("HOME")}/.config/theme-mode`
        watchChanges: true
    }
}
