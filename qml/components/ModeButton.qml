import QtQuick
import EvHmi

Rectangle {
    id: root

    property string text: ""
    property bool selected: false
    property color accentColor: Colors.accentEco

    signal clicked()

    radius: Theme.controlRadius
    color: selected ? accentColor : Colors.surfaceRaised
    border.color: selected ? accentColor : Colors.borderSubtle
    border.width: 1

    Text {
        anchors.centerIn: parent
        text: root.text
        color: root.selected ? Colors.backgroundPrimary : Colors.textSecondary
        font.family: Typography.family
        font.pixelSize: Typography.bodySmall
        font.weight: Font.DemiBold
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
    }
}
