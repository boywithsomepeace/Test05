#pragma once

#include <QMetaType>
#include <QString>
#include <QtGlobal>

struct VehicleTelemetry
{
    int speed = 0;
    int rpm = 0;
    int batteryPercent = 82;
    int rangeKm = 332;

    int motorTemp = 32;
    int batteryTemp = 29;
    int controllerTemp = 31;

    QString driveMode = QStringLiteral("ECO");
    QString gearState = QStringLiteral("D");

    bool leftIndicator = false;
    bool rightIndicator = false;
    bool hazardLights = false;
    bool headlights = false;
    bool highBeam = false;

    bool charging = false;
    float chargingPower = 0.0F;
    int chargeTimeRemaining = 0;

    float batteryVoltage = 0.0F;
    float batteryCurrent = 0.0F;
    float motorPower = 0.0F;
    int regenLevel = 0;

    qreal odometer = 12458.2;
    qreal tripDistance = 0.0;

    QString warningMessage;
    bool lowBatteryWarning = false;
    bool motorOverTempWarning = false;
    bool batteryOverTempWarning = false;
    bool communicationFault = true;
};

Q_DECLARE_METATYPE(VehicleTelemetry)
