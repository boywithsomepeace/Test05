import QtQuick
import QtQuick.Layouts
import EvHmi

Item {
    id: root

    function t(key) {
        settingsManager.revision
        return settingsManager.text(key)
    }

    GridLayout {
        anchors.fill: parent
        columns: 12
        rows: 6
        columnSpacing: Theme.cardGap
        rowSpacing: Theme.cardGap

        BaseCard {
            Layout.column: 0
            Layout.row: 0
            Layout.columnSpan: 7
            Layout.rowSpan: 6
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: root.t("Now Playing")
            baseColor: Colors.surfaceRaised

            ColumnLayout {
                anchors.fill: parent
                spacing: Math.round(16 * Theme.scale)

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: Math.round(210 * Theme.scale)
                    Layout.preferredHeight: Math.round(210 * Theme.scale)
                    radius: Theme.cardRadius
                    color: Colors.albumBase

                    Text {
                        anchors.centerIn: parent
                        text: "♪"
                        color: Colors.backgroundPrimary
                        font.family: Typography.family
                        font.pixelSize: Math.round(92 * Theme.scale)
                        font.weight: Font.DemiBold
                    }
                }

                MediaCard {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.round(112 * Theme.scale)
                }

                Item { Layout.fillHeight: true }
            }
        }

        BaseCard {
            Layout.column: 7
            Layout.row: 0
            Layout.columnSpan: 5
            Layout.rowSpan: 6
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: root.t("Queue")

            ColumnLayout {
                anchors.fill: parent
                spacing: Theme.cardGap

                Repeater {
                    model: ["What do you mean?", "Future Nostalgia", "Electric Feel", "Midnight City"]

                    MetricTile {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Math.round(64 * Theme.scale)
                        label: root.t("Media")
                        value: modelData
                        valueColor: index === 0 ? Colors.accentPrimary : Colors.textWarm
                    }
                }

                Item { Layout.fillHeight: true }
            }
        }
    }
}
