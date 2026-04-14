import QtQuick
import QtQuick.Layouts
import "../theme"

Rectangle {
    default property alias content: body.data
    property string title: ""

    color: Theme.bg
    radius: 8
    border.width: 1
    border.color: Theme.border

    ColumnLayout {
        id: body
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        Text {
            visible: title.length > 0
            text: title
            color: Theme.fg
            font.family: "Inter"
            font.pixelSize: 16
            font.weight: Font.DemiBold
        }
    }
}
