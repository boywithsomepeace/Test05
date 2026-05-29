import QtQuick
import QtQuick.Layouts
import EvHmi

Item {
    id: root

    readonly property bool imperial: settingsManager.unitSystem === "imperial"
    readonly property int speedLimit: vehicleData.driveMode === "SPORT" ? 126
        : vehicleData.driveMode === "CITY" ? 92 : 78
    readonly property color speedColor: Colors.accentPrimary
    readonly property color modeColor: vehicleData.driveMode === "SPORT" ? Colors.accentSport
        : vehicleData.driveMode === "CITY" ? Colors.accentCity : Colors.accentEco
    readonly property bool activeWarning: vehicleData.communicationFault
        || vehicleData.warningMessage.length > 0
        || vehicleData.lowBatteryWarning
        || vehicleData.motorOverTempWarning
        || vehicleData.batteryOverTempWarning

    function t(key) {
        settingsManager.revision
        return settingsManager.text(key)
    }

    function distance(km) {
        return root.imperial ? (km * 0.621371).toFixed(km < 20 ? 1 : 0) + " mi" : km.toFixed(km < 20 ? 1 : 0) + " km"
    }

    function temp(c) {
        return root.imperial ? Math.round(c * 9 / 5 + 32) + " F" : Math.round(c) + " C"
    }

    GridLayout {
        anchors.fill: parent
        columns: 12
        rows: 8
        columnSpacing: Theme.cardGap
        rowSpacing: Theme.cardGap

        BaseCard {
            Layout.column: 0
            Layout.row: 0
            Layout.columnSpan: 4
            Layout.rowSpan: 8
            Layout.fillWidth: true
            Layout.fillHeight: true
            padding: Math.round(16 * Theme.scale)
            baseColor: "#EDF8E9"
            outlineColor: "#314149"

            Item {
                anchors.fill: parent

                Column {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    spacing: Math.round(2 * Theme.scale)

                    Text {
                        text: root.imperial ? Math.round(vehicleData.speed * 0.621371) : vehicleData.speed
                        color: Colors.backgroundPrimary
                        font.family: Typography.family
                        font.pixelSize: Math.round(50 * Theme.scale)
                        font.weight: Font.DemiBold
                    }

                    Text {
                        text: root.imperial ? "mph" : "km/h"
                        color: "#57625C"
                        font.family: Typography.family
                        font.pixelSize: Typography.bodySmall
                        font.weight: Font.DemiBold
                    }
                }

                Item {
                    anchors.centerIn: parent
                    width: Math.min(parent.width * 0.72, parent.height * 0.46)
                    height: parent.height * 0.72

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        width: parent.width * 0.56
                        height: parent.height * 0.92
                        radius: width / 2
                        color: "#151A1B"
                        border.color: "#41494A"
                        border.width: Math.round(2 * Theme.scale)
                    }

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: parent.height * 0.12
                        width: parent.width * 0.34
                        height: parent.height * 0.45
                        radius: width / 2
                        color: "#242A2B"
                    }

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        width: parent.width * 0.68
                        height: parent.height * 0.50
                        radius: Math.round(60 * Theme.scale)
                        color: "#0D1011"
                    }
                }

                Column {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: Math.round(16 * Theme.scale)
                    spacing: Math.round(8 * Theme.scale)

                    Repeater {
                        model: ["P", "R", "N", "D"]
                        Text {
                            text: modelData
                            color: vehicleData.gearState === modelData ? Colors.backgroundPrimary : "#849083"
                            font.family: Typography.family
                            font.pixelSize: Typography.bodySmall
                            font.weight: vehicleData.gearState === modelData ? Font.DemiBold : Font.Medium

                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -8
                                onClicked: vehicleData.gearState = modelData
                            }
                        }
                    }
                }

                BaseCard {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: Math.round(126 * Theme.scale)
                    padding: Math.round(10 * Theme.scale)
                    baseColor: "#C5CAA1"
                    outlineColor: "#CDD4AE"

                    GridLayout {
                        anchors.fill: parent
                        columns: 3
                        rows: 2
                        columnSpacing: Math.round(7 * Theme.scale)
                        rowSpacing: Math.round(7 * Theme.scale)

                        Repeater {
                            model: [
                                { label: vehicleData.driveMode, active: true },
                                { label: root.t("Range"), active: false },
                                { label: root.t("System"), active: root.activeWarning },
                                { label: "L", active: vehicleData.leftIndicator || vehicleData.hazardLights },
                                { label: "R", active: vehicleData.rightIndicator || vehicleData.hazardLights },
                                { label: "HB", active: vehicleData.highBeam }
                            ]

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: Theme.controlRadius
                                color: modelData.active ? Qt.rgba(root.modeColor.r, root.modeColor.g, root.modeColor.b, 0.36) : Qt.rgba(1, 1, 1, 0.28)

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.label
                                    color: Colors.backgroundPrimary
                                    font.family: Typography.family
                                    font.pixelSize: Typography.label
                                    font.weight: Font.DemiBold
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }
            }
        }

        BaseCard {
            Layout.column: 4
            Layout.row: 0
            Layout.columnSpan: 4
            Layout.rowSpan: 3
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: root.t("Energy")

            ColumnLayout {
                anchors.fill: parent
                spacing: Math.round(9 * Theme.scale)

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        Layout.fillWidth: true
                        text: vehicleData.batteryPercent + "%"
                        color: vehicleData.lowBatteryWarning ? Colors.warning : Colors.textPrimary
                        font.family: Typography.family
                        font.pixelSize: Typography.displaySmall
                        font.weight: Font.DemiBold
                    }

                    Text {
                        text: root.distance(vehicleData.rangeKm)
                        color: Colors.textSecondary
                        font.family: Typography.family
                        font.pixelSize: Typography.titleMedium
                        font.weight: Font.DemiBold
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.round(12 * Theme.scale)
                    radius: height / 2
                    color: Colors.surfacePressed

                    Rectangle {
                        width: parent.width * Math.max(0, Math.min(1, vehicleData.batteryPercent / 100))
                        height: parent.height
                        radius: parent.radius
                        color: vehicleData.lowBatteryWarning ? Colors.warning : Colors.accentPrimary
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    MetricTile {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Math.round(52 * Theme.scale)
                        label: root.t("Power Output")
                        value: vehicleData.motorPower.toFixed(1) + " kW"
                    }
                    MetricTile {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Math.round(52 * Theme.scale)
                        label: "Regen"
                        value: vehicleData.regenLevel
                    }
                }
            }
        }

        BaseCard {
            Layout.column: 4
            Layout.row: 3
            Layout.columnSpan: 4
            Layout.rowSpan: 3
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: root.t("Drive Mode")

            ColumnLayout {
                anchors.fill: parent
                spacing: Math.round(7 * Theme.scale)

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

        BaseCard {
            Layout.column: 4
            Layout.row: 6
            Layout.columnSpan: 2
            Layout.rowSpan: 2
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: root.t("Temperature")

            ColumnLayout {
                anchors.fill: parent
                spacing: Theme.cardGap

                MetricTile {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    label: root.t("Motor")
                    value: root.temp(vehicleData.motorTemp)
                    valueColor: vehicleData.motorOverTempWarning ? Colors.warning : Colors.textWarm
                }

                MetricTile {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    label: root.t("Battery")
                    value: root.temp(vehicleData.batteryTemp)
                    valueColor: vehicleData.batteryOverTempWarning ? Colors.warning : Colors.textWarm
                }
            }
        }

        BaseCard {
            Layout.column: 6
            Layout.row: 6
            Layout.columnSpan: 2
            Layout.rowSpan: 2
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: root.t("Trip")

            ColumnLayout {
                anchors.fill: parent
                spacing: Theme.cardGap

                MetricTile {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    label: root.t("Odometer")
                    value: root.distance(vehicleData.odometer)
                }

                MetricTile {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    label: root.t("Trip")
                    value: root.distance(vehicleData.tripDistance)
                }
            }
        }

        BaseCard {
            Layout.column: 8
            Layout.row: 0
            Layout.columnSpan: 4
            Layout.rowSpan: 5
            Layout.fillWidth: true
            Layout.fillHeight: true
            padding: Math.round(11 * Theme.scale)
            baseColor: Colors.mapBase

            Item {
                anchors.fill: parent

                Repeater {
                    model: 8
                    Rectangle {
                        x: parent.width * (index / 7)
                        y: parent.height * (0.15 + 0.08 * Math.sin(index))
                        width: Math.round(2 * Theme.scale)
                        height: parent.height * 0.78
                        rotation: -18
                        color: index % 2 ? "#344044" : "#273137"
                    }
                }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    width: parent.width * 0.56
                    height: parent.height * 1.15
                    radius: Math.round(26 * Theme.scale)
                    color: "#2F3634"
                    border.color: "#66706A"
                    border.width: 1
                    rotation: -2
                }

                Repeater {
                    model: 3
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: parent.height * (0.33 + index * 0.19)
                        width: parent.width * (0.12 + index * 0.04)
                        height: Math.round(16 * Theme.scale)
                        rotation: -2
                        color: Colors.mapRoad
                    }
                }

                BaseCard {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    width: Math.round(150 * Theme.scale)
                    height: Math.round(70 * Theme.scale)
                    padding: Math.round(8 * Theme.scale)
                    baseColor: "#E4F4D5"
                    outlineColor: "#F1F6E4"

                    Column {
                        anchors.fill: parent
                        spacing: Math.round(2 * Theme.scale)
                        Text {
                            width: parent.width
                            text: root.distance(vehicleData.rangeKm)
                            color: Colors.backgroundPrimary
                            font.family: Typography.family
                            font.pixelSize: Typography.bodyMedium
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }
                        Text {
                            width: parent.width
                            text: root.t("Range")
                            color: "#53615A"
                            font.family: Typography.family
                            font.pixelSize: Typography.label
                            font.weight: Font.Medium
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }

        MediaCard {
            Layout.column: 8
            Layout.row: 5
            Layout.columnSpan: 4
            Layout.rowSpan: 3
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
