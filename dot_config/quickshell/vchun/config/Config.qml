pragma Singleton

import Quickshell

Singleton {
    readonly property var workspaces: [1, 2, 3, 4, 5]

    readonly property int barHeight: 54
    readonly property int barExclusiveZone: 60
    readonly property int barMarginTop: 6
    readonly property int barMarginSide: 10
    readonly property int barPaddingSide: 12
    readonly property int barSpacing: 10
    readonly property int groupSpacing: 8

    readonly property int chipHeight: 30
    readonly property int chipPaddingX: 20
    readonly property int chipRadius: 8
    readonly property int chipValueMaxWidth: 280

    readonly property int windowTitleMaxChars: 48
    readonly property int networkNameMaxChars: 22
    readonly property int mediaMaxChars: 32
    readonly property int resourcesIntervalMs: 2500
    readonly property int statusIntervalMs: 1000
}
