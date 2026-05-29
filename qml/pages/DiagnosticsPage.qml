import QtQuick
import QtQuick.Layouts
import EvHmi

Item {
    id: root

    property var speedHistory: []
    property var batteryHistory: []
    property var motorTempHistory: []
    property var batteryTempHistory: []
    property var currentHistory: []
    property var powerHistory: []

    readonly property bool imperial: settingsManager.unitSystem === "imperial"

    function t(key) {
        settingsManager.revision
        return settingsManager.text(key)
    }

    function pushSample(list, value) {
        var next = list.slice()
        next.push(value)
        while (next.length > 48) {
            next.shift()
        }
        return next
    }

    function captureTelemetry() {
        speedHistory = pushSample(speedHistory, root.imperial ? vehicleData.speed * 0.621371 : vehicleData.speed)
        batteryHistory = pushSample(batteryHistory, vehicleData.batteryPercent)
        motorTempHistory = pushSample(motorTempHistory, root.imperial ? vehicleData.motorTemp * 9 / 5 + 32 : vehicleData.motorTemp)
        batteryTempHistory = pushSample(batteryTempHistory, root.imperial ? vehicleData.batteryTemp * 9 / 5 + 32 : vehicleData.batteryTemp)
        currentHistory = pushSample(currentHistory, vehicleData.batteryCurrent)
        powerHistory = pushSample(powerHistory, vehicleData.motorPower)
    }

    Component.onCompleted: {
        for (var i = 0; i < 24; ++i) {
            captureTelemetry()
        }
    }

    Connections {
        target: vehicleData
        function onTelemetryChanged() {
            captureTelemetry()
        }
    }

    GridLayout {
        anchors.fill: parent
        columns: 3
        rows: 3
        columnSpacing: Theme.cardGap
        rowSpacing: Theme.cardGap

        Repeater {
            model: [
                {
                    title: root.t("Speed"),
                    samples: root.speedHistory,
                    min: 0,
                    max: root.imperial ? 85 : 140,
                    unit: root.imperial ? "mph" : "km/h",
                    current: root.imperial ? Math.round(vehicleData.speed * 0.621371) + " mph" : vehicleData.speed + " km/h",
                    color: Colors.accentPrimary
                },
                {
                    title: root.t("Battery"),
                    samples: root.batteryHistory,
                    min: 0,
                    max: 100,
                    unit: "%",
                    current: vehicleData.batteryPercent + "%",
                    color: vehicleData.lowBatteryWarning ? Colors.warning : Colors.accentEco
                },
                {
                    title: root.t("Motor Temp"),
                    samples: root.motorTempHistory,
                    min: root.imperial ? 50 : 10,
                    max: root.imperial ? 220 : 105,
                    unit: root.imperial ? "F" : "C",
                    current: root.imperial ? Math.round(vehicleData.motorTemp * 9 / 5 + 32) + " F" : vehicleData.motorTemp + " C",
                    color: vehicleData.motorOverTempWarning ? Colors.warning : Colors.accentSecondary
                },
                {
                    title: root.t("Battery Temp"),
                    samples: root.batteryTempHistory,
                    min: root.imperial ? 50 : 10,
                    max: root.imperial ? 180 : 82,
                    unit: root.imperial ? "F" : "C",
                    current: root.imperial ? Math.round(vehicleData.batteryTemp * 9 / 5 + 32) + " F" : vehicleData.batteryTemp + " C",
                    color: vehicleData.batteryOverTempWarning ? Colors.warning : Colors.accentCity
                },
                {
                    title: root.t("Current Draw"),
                    samples: root.currentHistory,
                    min: 0,
                    max: 125,
                    unit: "A",
                    current: vehicleData.batteryCurrent.toFixed(1) + " A",
                    color: Colors.textWarm
                },
                {
                    title: root.t("Power Output"),
                    samples: root.powerHistory,
                    min: 0,
                    max: 42,
                    unit: "kW",
                    current: vehicleData.motorPower.toFixed(1) + " kW",
                    color: Colors.accentSport
                }
            ]

            GraphCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                title: modelData.title
                samples: modelData.samples
                minimumValue: modelData.min
                maximumValue: modelData.max
                unit: modelData.unit
                currentText: modelData.current
                lineColor: modelData.color
            }
        }

        BaseCard {
            Layout.columnSpan: 3
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: root.t("Telemetry")

            GridLayout {
                anchors.fill: parent
                columns: 4
                columnSpacing: Theme.cardGap
                rowSpacing: Theme.cardGap

                MetricTile {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    label: root.t("Gear")
                    value: vehicleData.gearState
                }
                MetricTile {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    label: root.t("Drive Mode")
                    value: vehicleData.driveMode
                    valueColor: vehicleData.driveMode === "SPORT" ? Colors.accentSport
                        : vehicleData.driveMode === "CITY" ? Colors.accentCity : Colors.accentEco
                }
                MetricTile {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    label: root.t("Odometer")
                    value: root.imperial ? (vehicleData.odometer * 0.621371).toFixed(1) + " mi" : vehicleData.odometer.toFixed(1) + " km"
                }
                MetricTile {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    label: root.t("Communication")
                    value: vehicleData.communicationFault ? root.t("Fault") : root.t("Online")
                    valueColor: vehicleData.communicationFault ? Colors.critical : Colors.accentEco
                }
            }
        }
    }
}
