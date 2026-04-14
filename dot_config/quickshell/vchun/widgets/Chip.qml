import QtQuick
import QtQuick.Layouts
import "../theme"

Rectangle {
    property string label: ""
    property string value: ""

    implicitHeight: 30
    implicitWidth: content.implicitWidth + 20
    radius: 8
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
            Layout.maximumWidth: 280
        }
    }
}
