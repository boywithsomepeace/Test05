import QtQuick
import QtQuick.Layouts
import EvHmi

BaseCard {
    id: root

    property string artist: "Dua Lipa & Justin"
    property string track: "What do you mean?"
    property bool playing: true

    baseColor: Colors.mediaSurface
    outlineColor: Colors.mediaBorder

    RowLayout {
        anchors.fill: parent
        spacing: Math.round(12 * Theme.scale)

        Rectangle {
            Layout.preferredWidth: Math.round(86 * Theme.scale)
            Layout.fillHeight: true
            radius: Theme.controlRadius
            color: Colors.albumBase
            border.color: Colors.borderSubtle
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: "♪"
                color: Colors.backgroundPrimary
                font.family: Typography.family
                font.pixelSize: Typography.displaySmall
                font.weight: Font.DemiBold
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Math.round(5 * Theme.scale)

            Text {
                Layout.fillWidth: true
                text: root.track
                color: Colors.backgroundPrimary
                elide: Text.ElideRight
                font.family: Typography.family
                font.pixelSize: Typography.bodyMedium
                font.weight: Font.DemiBold
            }

            Text {
                Layout.fillWidth: true
                text: root.artist
                color: Qt.rgba(0, 0, 0, 0.58)
                elide: Text.ElideRight
                font.family: Typography.family
                font.pixelSize: Typography.label
                font.weight: Font.Medium
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Math.round(4 * Theme.scale)
                radius: height / 2
                color: Qt.rgba(0, 0, 0, 0.22)

                Rectangle {
                    width: parent.width * 0.62
                    height: parent.height
                    radius: parent.radius
                    color: Colors.backgroundPrimary
                }
            }
        }

        Rectangle {
            Layout.preferredWidth: Math.round(36 * Theme.scale)
            Layout.preferredHeight: Math.round(36 * Theme.scale)
            radius: width / 2
            color: Qt.rgba(0, 0, 0, 0.16)

            Text {
                anchors.centerIn: parent
                text: root.playing ? "II" : ">"
                color: Colors.backgroundPrimary
                font.family: Typography.family
                font.pixelSize: Typography.bodySmall
                font.weight: Font.DemiBold
            }
        }
    }
}
