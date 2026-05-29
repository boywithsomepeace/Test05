import QtQuick
import EvHmi

Rectangle {
    id: root

    default property alias content: contentLayer.data
    property string title: ""
    property bool interactive: false
    property color baseColor: Colors.surfaceBase
    property color pressedColor: Colors.surfacePressed
    property color outlineColor: Colors.borderSubtle
    property int padding: Theme.cardPadding

    signal tapped()

    color: touchArea.pressed && interactive ? pressedColor : baseColor
    radius: Theme.cardRadius
    border.color: outlineColor
    border.width: 1
    clip: true

    Behavior on color {
        ColorAnimation {
            duration: Theme.motionFast
            easing.type: Easing.OutCubic
        }
    }

    MouseArea {
        id: touchArea
        anchors.fill: parent
        enabled: root.interactive
        onClicked: root.tapped()
    }

    Text {
        id: heading
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: root.padding
        visible: root.title.length > 0
        text: root.title
        color: Colors.textSecondary
        font.family: Typography.family
        font.pixelSize: Typography.label
        font.weight: Font.DemiBold
        elide: Text.ElideRight
    }

    Item {
        id: contentLayer
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: root.padding
        anchors.rightMargin: root.padding
        anchors.bottomMargin: root.padding
        anchors.top: heading.visible ? heading.bottom : parent.top
        anchors.topMargin: heading.visible ? Math.round(10 * Theme.scale) : root.padding
    }
}
