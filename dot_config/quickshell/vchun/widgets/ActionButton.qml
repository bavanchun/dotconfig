import QtQuick
import QtQuick.Layouts
import "../config"
import "../theme"

Rectangle {
    id: root
    property string label: ""
    property string value: ""
    signal pressed()

    implicitHeight: 38
    implicitWidth: Math.max(120, row.implicitWidth + 22)
    radius: Config.chipRadius
    color: mouse.containsMouse ? Theme.accent : Theme.bgAlt
    border.width: 1
    border.color: Theme.border

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 8

        Text {
            text: root.label
            color: mouse.containsMouse ? Theme.accentText : Theme.fg
            font.family: "Inter"
            font.pixelSize: 12
            font.weight: Font.DemiBold
        }

        Text {
            visible: root.value.length > 0
            text: root.value
            color: mouse.containsMouse ? Theme.accentText : Theme.muted
            font.family: "Inter"
            font.pixelSize: 12
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.pressed()
    }
}
