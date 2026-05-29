import QtQuick
import QtQuick.Controls
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
            Layout.columnSpan: 5
            Layout.rowSpan: 6
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: root.t("Display")

            ColumnLayout {
                anchors.fill: parent
                spacing: Math.round(14 * Theme.scale)

                ControlRow {
                    Layout.fillWidth: true
                    title: root.t("Brightness")
                    value: Math.round(settingsManager.brightness * 100) + "%"
                    sliderValue: settingsManager.brightness
                    onSliderMoved: settingsManager.brightness = sliderValue
                }

                ControlRow {
                    Layout.fillWidth: true
                    title: root.t("Contrast")
                    value: Math.round(settingsManager.contrast * 100) + "%"
                    fromValue: 0.0
                    sliderValue: settingsManager.contrast
                    onSliderMoved: settingsManager.contrast = sliderValue
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.round(96 * Theme.scale)
                    radius: Theme.controlRadius
                    color: Colors.transparentPanel
                    border.color: Colors.borderSubtle

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: Math.round(12 * Theme.scale)
                        spacing: Math.round(12 * Theme.scale)

                        Rectangle {
                            Layout.preferredWidth: Math.round(70 * Theme.scale)
                            Layout.fillHeight: true
                            radius: Theme.controlRadius
                            color: Colors.accentPrimary
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            Text {
                                Layout.fillWidth: true
                                text: root.t("System")
                                color: Colors.textPrimary
                                font.family: Typography.family
                                font.pixelSize: Typography.titleMedium
                                font.weight: Font.DemiBold
                            }

                            Text {
                                Layout.fillWidth: true
                                text: root.t("LIVE TELEMETRY")
                                color: Colors.textMuted
                                font.family: Typography.family
                                font.pixelSize: Typography.bodySmall
                            }
                        }
                    }
                }

                Item { Layout.fillHeight: true }
            }
        }

        BaseCard {
            Layout.column: 5
            Layout.row: 0
            Layout.columnSpan: 7
            Layout.rowSpan: 2
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: root.t("Units")

            RowLayout {
                anchors.fill: parent
                spacing: Theme.cardGap

                ModeButton {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: root.t("Metric")
                    selected: settingsManager.unitSystem === "metric"
                    accentColor: Colors.accentPrimary
                    onClicked: settingsManager.unitSystem = "metric"
                }

                ModeButton {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: root.t("Imperial")
                    selected: settingsManager.unitSystem === "imperial"
                    accentColor: Colors.accentPrimary
                    onClicked: settingsManager.unitSystem = "imperial"
                }
            }
        }

        BaseCard {
            Layout.column: 5
            Layout.row: 2
            Layout.columnSpan: 7
            Layout.rowSpan: 2
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: root.t("Language")

            RowLayout {
                anchors.fill: parent
                spacing: Theme.cardGap

                Repeater {
                    model: [
                        { code: "en", label: root.t("English") },
                        { code: "de", label: root.t("German") },
                        { code: "es", label: root.t("Spanish") }
                    ]

                    ModeButton {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        text: modelData.label
                        selected: settingsManager.language === modelData.code
                        accentColor: Colors.accentSecondary
                        onClicked: settingsManager.language = modelData.code
                    }
                }
            }
        }

        BaseCard {
            Layout.column: 5
            Layout.row: 4
            Layout.columnSpan: 7
            Layout.rowSpan: 2
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: root.t("Drive Mode")

            RowLayout {
                anchors.fill: parent
                spacing: Theme.cardGap

                Repeater {
                    model: ["ECO", "CITY", "SPORT"]

                    ModeButton {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        text: modelData
                        selected: vehicleData.driveMode === modelData
                        accentColor: modelData === "SPORT" ? Colors.accentSport
                            : modelData === "CITY" ? Colors.accentCity : Colors.accentEco
                        onClicked: vehicleData.driveMode = modelData
                    }
                }
            }
        }
    }

    component ControlRow: Item {
        id: control

        property string title: ""
        property string value: ""
        property real fromValue: 0.3
        property real sliderValue: 0

        signal sliderMoved()

        height: Math.round(72 * Theme.scale)

        ColumnLayout {
            anchors.fill: parent
            spacing: Math.round(8 * Theme.scale)

            RowLayout {
                Layout.fillWidth: true

                Text {
                    Layout.fillWidth: true
                    text: control.title
                    color: Colors.textPrimary
                    font.family: Typography.family
                    font.pixelSize: Typography.bodyMedium
                    font.weight: Font.DemiBold
                }

                Text {
                    text: control.value
                    color: Colors.textMuted
                    font.family: Typography.family
                    font.pixelSize: Typography.bodySmall
                    font.weight: Font.DemiBold
                }
            }

            Slider {
                Layout.fillWidth: true
                from: control.fromValue
                to: 1.0
                value: control.sliderValue
                onMoved: {
                    control.sliderValue = value
                    control.sliderMoved()
                }
            }
        }
    }
}
