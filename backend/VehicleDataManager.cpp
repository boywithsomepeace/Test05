#include "backend/VehicleDataManager.h"

#include <QStringList>

VehicleDataManager::VehicleDataManager(QObject *parent)
    : QObject(parent)
{
}

int VehicleDataManager::speed() const { return m_telemetry.speed; }
int VehicleDataManager::rpm() const { return m_telemetry.rpm; }
int VehicleDataManager::batteryPercent() const { return m_telemetry.batteryPercent; }
int VehicleDataManager::rangeKm() const { return m_telemetry.rangeKm; }
int VehicleDataManager::motorTemp() const { return m_telemetry.motorTemp; }
int VehicleDataManager::batteryTemp() const { return m_telemetry.batteryTemp; }
int VehicleDataManager::controllerTemp() const { return m_telemetry.controllerTemp; }
QString VehicleDataManager::driveMode() const { return m_telemetry.driveMode; }
QString VehicleDataManager::gearState() const { return m_telemetry.gearState; }
bool VehicleDataManager::leftIndicator() const { return m_telemetry.leftIndicator; }
bool VehicleDataManager::rightIndicator() const { return m_telemetry.rightIndicator; }
bool VehicleDataManager::hazardLights() const { return m_telemetry.hazardLights; }
bool VehicleDataManager::headlights() const { return m_telemetry.headlights; }
bool VehicleDataManager::highBeam() const { return m_telemetry.highBeam; }
bool VehicleDataManager::charging() const { return m_telemetry.charging; }
float VehicleDataManager::chargingPower() const { return m_telemetry.chargingPower; }
int VehicleDataManager::chargeTimeRemaining() const { return m_telemetry.chargeTimeRemaining; }
float VehicleDataManager::batteryVoltage() const { return m_telemetry.batteryVoltage; }
float VehicleDataManager::batteryCurrent() const { return m_telemetry.batteryCurrent; }
float VehicleDataManager::motorPower() const { return m_telemetry.motorPower; }
int VehicleDataManager::regenLevel() const { return m_telemetry.regenLevel; }
double VehicleDataManager::odometer() const { return m_telemetry.odometer; }
double VehicleDataManager::tripDistance() const { return m_telemetry.tripDistance; }
QString VehicleDataManager::warningMessage() const { return m_telemetry.warningMessage; }
bool VehicleDataManager::lowBatteryWarning() const { return m_telemetry.lowBatteryWarning; }
bool VehicleDataManager::motorOverTempWarning() const { return m_telemetry.motorOverTempWarning; }
bool VehicleDataManager::batteryOverTempWarning() const { return m_telemetry.batteryOverTempWarning; }
bool VehicleDataManager::communicationFault() const { return m_telemetry.communicationFault; }

void VehicleDataManager::applyTelemetry(const VehicleTelemetry &telemetry)
{
    const bool gearWasChanged = m_telemetry.gearState != telemetry.gearState;
    const bool driveModeWasChanged = m_telemetry.driveMode != telemetry.driveMode;

    m_telemetry = telemetry;

    emit telemetryChanged();

    if (gearWasChanged) {
        emit gearStateChanged();
    }

    if (driveModeWasChanged) {
        emit driveModeChanged();
    }
}

void VehicleDataManager::setGearState(const QString &gearState)
{
    const QString normalized = normalizedGearState(gearState);
    if (normalized.isEmpty() || normalized == m_telemetry.gearState) {
        return;
    }

    m_telemetry.gearState = normalized;
    emit gearStateChanged();
    emit telemetryChanged();
    emit gearRequested(normalized);
}

void VehicleDataManager::setDriveMode(const QString &driveMode)
{
    const QString normalized = normalizedDriveMode(driveMode);
    if (normalized.isEmpty() || normalized == m_telemetry.driveMode) {
        return;
    }

    m_telemetry.driveMode = normalized;
    emit driveModeChanged();
    emit telemetryChanged();
    emit driveModeRequested(normalized);
}

void VehicleDataManager::setSimulationActive(bool active)
{
    const bool fault = !active;
    if (m_telemetry.communicationFault == fault) {
        return;
    }

    m_telemetry.communicationFault = fault;
    emit telemetryChanged();
}

QString VehicleDataManager::normalizedGearState(const QString &gearState)
{
    const QString value = gearState.trimmed().toUpper();
    static const QStringList validGears = {
        QStringLiteral("P"),
        QStringLiteral("N"),
        QStringLiteral("R"),
        QStringLiteral("D"),
    };

    return validGears.contains(value) ? value : QString();
}

QString VehicleDataManager::normalizedDriveMode(const QString &driveMode)
{
    const QString value = driveMode.trimmed().toUpper();
    static const QStringList validModes = {
        QStringLiteral("ECO"),
        QStringLiteral("CITY"),
        QStringLiteral("SPORT"),
    };

    return validModes.contains(value) ? value : QString();
}
