import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import "../../config"

RowLayout {
    id: root
    spacing: Config.groupSpacing

    Repeater {
        model: SystemTray.items.values

        MouseArea {
            required property SystemTrayItem modelData

            Layout.preferredWidth: 20
            Layout.preferredHeight: 20
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            cursorShape: Qt.PointingHandCursor

            onClicked: event => {
                if (event.button === Qt.RightButton && modelData.hasMenu)
                    modelData.display(root.QsWindow.window, x, height);
                else
                    modelData.activate();
            }

            IconImage {
                anchors.fill: parent
                source: parent.modelData.icon
            }
        }
    }
}
