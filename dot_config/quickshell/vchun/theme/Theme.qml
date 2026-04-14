pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "."

Singleton {
    readonly property string mode: themeMode.loaded ? themeMode.text().trim() : "dark"
    readonly property bool light: mode === "light"

    readonly property color bg: light ? Generated.lightBg : Generated.darkBg
    readonly property color bgAlt: light ? Generated.lightBgAlt : Generated.darkBgAlt
    readonly property color fg: light ? Generated.lightFg : Generated.darkFg
    readonly property color muted: light ? Generated.lightMuted : Generated.darkMuted
    readonly property color border: light ? Generated.lightBorder : Generated.darkBorder
    readonly property color accent: Generated.accent
    readonly property color accentText: Generated.accentText

    FileView {
        id: themeMode
        path: `${Quickshell.env("HOME")}/.config/theme-mode`
        watchChanges: true
    }
}
