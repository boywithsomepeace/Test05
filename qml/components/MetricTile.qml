import QtQuick
import EvHmi

Rectangle {
    id: root

    property string label: ""
    property string value: ""
    property color valueColor: Colors.textWarm

    radius: Theme.controlRadius
    color: Colors.transparentPanel
    border.color: Colors.borderSubtle
    border.width: 1

    Column {
        anchors.fill: parent
        anchors.margins: Math.round(10 * Theme.scale)
        spacing: Math.round(3 * Theme.scale)

        Text {
            width: parent.width
            text: root.label
            color: Colors.textMuted
            elide: Text.ElideRight
            font.family: Typography.family
            font.pixelSize: Typography.label
            font.weight: Font.Medium
        }

        Text {
            width: parent.width
            text: root.value
            color: root.valueColor
            elide: Text.ElideRight
            font.family: Typography.family
            font.pixelSize: Typography.bodyLarge
            font.weight: Font.DemiBold
        }
    }
}
