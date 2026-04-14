pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property color darkBg: "{{colors.surface.default.hex}}"
    readonly property color darkBgAlt: "{{colors.surface_container.default.hex}}"
    readonly property color darkFg: "{{colors.on_surface.default.hex}}"
    readonly property color darkMuted: "{{colors.on_surface_variant.default.hex}}"
    readonly property color darkBorder: "{{colors.outline_variant.default.hex}}"

    readonly property color lightBg: "{{colors.surface.default.hex}}"
    readonly property color lightBgAlt: "{{colors.surface_container.default.hex}}"
    readonly property color lightFg: "{{colors.on_surface.default.hex}}"
    readonly property color lightMuted: "{{colors.on_surface_variant.default.hex}}"
    readonly property color lightBorder: "{{colors.outline_variant.default.hex}}"

    readonly property color accent: "{{colors.primary.default.hex}}"
    readonly property color accentText: "{{colors.on_primary.default.hex}}"
}
