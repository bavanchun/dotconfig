import QtQuick
import QtQuick.Layouts
import "../config"
import "../theme"

Rectangle {
    property string label: ""
    property string value: ""

    implicitHeight: Config.chipHeight
    implicitWidth: content.implicitWidth + Config.chipPaddingX
    radius: Config.chipRadius
    color: Theme.bgAlt

    RowLayout {
        id: content
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: label
            color: Theme.muted
            font.family: "Inter"
            font.pixelSize: 10
            font.weight: Font.DemiBold
        }

        Text {
            text: value
            color: Theme.fg
            elide: Text.ElideRight
            font.family: "Inter"
            font.pixelSize: 12
            font.weight: Font.Medium
            Layout.maximumWidth: Config.chipValueMaxWidth
        }
    }
}
