import QtQuick
import EvHmi

Item {
    id: root

    property real value: 0
    property real rangeKm: 0
    property color activeColor: Colors.accentEco
    property color inactiveColor: Colors.accentCopperDim

    implicitHeight: Math.round(34 * Theme.scale)

    Text {
        id: leftLabel
        anchors.left: parent.left
        anchors.verticalCenter: bar.verticalCenter
        text: "E"
        color: Colors.textMuted
        font.family: Typography.family
        font.pixelSize: Typography.label
        font.weight: Font.DemiBold
    }

    Row {
        id: bar
        anchors.left: leftLabel.right
        anchors.right: rightLabel.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: Math.round(8 * Theme.scale)
        anchors.rightMargin: Math.round(8 * Theme.scale)
        spacing: Math.max(2, Math.round(3 * Theme.scale))

        Repeater {
            model: 44

            Rectangle {
                width: (bar.width - bar.spacing * 43) / 44
                height: Math.round(5 * Theme.scale)
                radius: height / 2
                color: index < Math.round(root.value / 100 * 44) ? root.activeColor : root.inactiveColor
                opacity: index < Math.round(root.value / 100 * 44) ? 0.92 : 0.42
            }
        }
    }

    Text {
        id: rightLabel
        anchors.right: parent.right
        anchors.verticalCenter: bar.verticalCenter
        text: Math.round(root.value) + "%"
        color: root.activeColor
        font.family: Typography.family
        font.pixelSize: Typography.label
        font.weight: Font.DemiBold
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: bar.top
        anchors.bottomMargin: Math.round(3 * Theme.scale)
        text: "Range " + Math.round(root.rangeKm) + " km"
        color: Colors.accentEco
        font.family: Typography.family
        font.pixelSize: Typography.label
        font.weight: Font.DemiBold
    }
}
