#pragma once

#include <QObject>
#include <QString>

#include "models/VehicleTelemetry.h"

class VehicleDataManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int speed READ speed NOTIFY telemetryChanged)
    Q_PROPERTY(int rpm READ rpm NOTIFY telemetryChanged)
    Q_PROPERTY(int batteryPercent READ batteryPercent NOTIFY telemetryChanged)
    Q_PROPERTY(int rangeKm READ rangeKm NOTIFY telemetryChanged)
    Q_PROPERTY(int motorTemp READ motorTemp NOTIFY telemetryChanged)
    Q_PROPERTY(int batteryTemp READ batteryTemp NOTIFY telemetryChanged)
    Q_PROPERTY(int controllerTemp READ controllerTemp NOTIFY telemetryChanged)
    Q_PROPERTY(QString driveMode READ driveMode WRITE setDriveMode NOTIFY driveModeChanged)
    Q_PROPERTY(QString gearState READ gearState WRITE setGearState NOTIFY gearStateChanged)
    Q_PROPERTY(bool leftIndicator READ leftIndicator NOTIFY telemetryChanged)
    Q_PROPERTY(bool rightIndicator READ rightIndicator NOTIFY telemetryChanged)
    Q_PROPERTY(bool hazardLights READ hazardLights NOTIFY telemetryChanged)
    Q_PROPERTY(bool headlights READ headlights NOTIFY telemetryChanged)
    Q_PROPERTY(bool highBeam READ highBeam NOTIFY telemetryChanged)
    Q_PROPERTY(bool charging READ charging NOTIFY telemetryChanged)
    Q_PROPERTY(float chargingPower READ chargingPower NOTIFY telemetryChanged)
    Q_PROPERTY(int chargeTimeRemaining READ chargeTimeRemaining NOTIFY telemetryChanged)
    Q_PROPERTY(float batteryVoltage READ batteryVoltage NOTIFY telemetryChanged)
    Q_PROPERTY(float batteryCurrent READ batteryCurrent NOTIFY telemetryChanged)
    Q_PROPERTY(float motorPower READ motorPower NOTIFY telemetryChanged)
    Q_PROPERTY(int regenLevel READ regenLevel NOTIFY telemetryChanged)
    Q_PROPERTY(double odometer READ odometer NOTIFY telemetryChanged)
    Q_PROPERTY(double tripDistance READ tripDistance NOTIFY telemetryChanged)
    Q_PROPERTY(QString warningMessage READ warningMessage NOTIFY telemetryChanged)
    Q_PROPERTY(bool lowBatteryWarning READ lowBatteryWarning NOTIFY telemetryChanged)
    Q_PROPERTY(bool motorOverTempWarning READ motorOverTempWarning NOTIFY telemetryChanged)
    Q_PROPERTY(bool batteryOverTempWarning READ batteryOverTempWarning NOTIFY telemetryChanged)
    Q_PROPERTY(bool communicationFault READ communicationFault NOTIFY telemetryChanged)

public:
    explicit VehicleDataManager(QObject *parent = nullptr);

    int speed() const;
    int rpm() const;
    int batteryPercent() const;
    int rangeKm() const;
    int motorTemp() const;
    int batteryTemp() const;
    int controllerTemp() const;
    QString driveMode() const;
    QString gearState() const;
    bool leftIndicator() const;
    bool rightIndicator() const;
    bool hazardLights() const;
    bool headlights() const;
    bool highBeam() const;
    bool charging() const;
    float chargingPower() const;
    int chargeTimeRemaining() const;
    float batteryVoltage() const;
    float batteryCurrent() const;
    float motorPower() const;
    int regenLevel() const;
    double odometer() const;
    double tripDistance() const;
    QString warningMessage() const;
    bool lowBatteryWarning() const;
    bool motorOverTempWarning() const;
    bool batteryOverTempWarning() const;
    bool communicationFault() const;

public slots:
    void applyTelemetry(const VehicleTelemetry &telemetry);
    void setGearState(const QString &gearState);
    void setDriveMode(const QString &driveMode);
    void setSimulationActive(bool active);

signals:
    void telemetryChanged();
    void gearStateChanged();
    void driveModeChanged();

    void gearRequested(const QString &gearState);
    void driveModeRequested(const QString &driveMode);

private:
    static QString normalizedGearState(const QString &gearState);
    static QString normalizedDriveMode(const QString &driveMode);

    VehicleTelemetry m_telemetry;
};
