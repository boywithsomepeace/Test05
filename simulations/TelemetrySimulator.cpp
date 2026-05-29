#include "simulations/TelemetrySimulator.h"

#include <cmath>

#include <QtMath>

TelemetrySimulator::TelemetrySimulator(QObject *parent)
    : QObject(parent)
{
    m_timer.setInterval(100);
    m_timer.setTimerType(Qt::PreciseTimer);

    connect(&m_timer, &QTimer::timeout, this, &TelemetrySimulator::updateFrame);
}

bool TelemetrySimulator::isRunning() const
{
    return m_timer.isActive();
}

void TelemetrySimulator::start()
{
    if (m_timer.isActive()) {
        return;
    }

    m_clock.restart();
    m_lastTickMs = m_clock.elapsed();
    m_timer.start();
    emit runningChanged(true);
    emitCurrentTelemetry();
}

void TelemetrySimulator::stop()
{
    if (!m_timer.isActive()) {
        return;
    }

    m_timer.stop();
    emit runningChanged(false);
}

void TelemetrySimulator::setDriveMode(const QString &driveMode)
{
    const QString normalized = driveMode.trimmed().toLower();

    if (normalized == QStringLiteral("eco")) {
        m_driveMode = QStringLiteral("ECO");
    } else if (normalized == QStringLiteral("city")) {
        m_driveMode = QStringLiteral("CITY");
    } else if (normalized == QStringLiteral("sport")) {
        m_driveMode = QStringLiteral("SPORT");
    }
}

void TelemetrySimulator::setGear(const QString &gear)
{
    const QString normalized = gear.trimmed().toUpper();

    if (normalized == QStringLiteral("P") || normalized == QStringLiteral("R")
        || normalized == QStringLiteral("N") || normalized == QStringLiteral("D")) {
        m_gear = normalized;
    }
}

void TelemetrySimulator::updateFrame()
{
    const qint64 nowMs = m_clock.elapsed();
    const qreal dt = clamp((nowMs - m_lastTickMs) / 1000.0, 0.001, 0.25);
    const qreal elapsedSeconds = nowMs / 1000.0;
    m_lastTickMs = nowMs;

    const ModeProfile profile = activeProfile();
    const qreal previousSpeed = m_speedKph;
    const qreal targetSpeed = targetSpeedForTime(elapsedSeconds);
    const qreal responseAlpha = 1.0 - qExp(-profile.response * dt);

    m_speedKph += (targetSpeed - m_speedKph) * responseAlpha;
    if (m_speedKph < 0.04) {
        m_speedKph = 0.0;
    }

    const qreal speedDelta = qAbs(m_speedKph - previousSpeed);
    const qreal accelerationLoad = clamp(speedDelta / (dt * 16.0), 0.0, 1.0);
    const qreal cruiseLoad = clamp(m_speedKph / profile.peakSpeedKph, 0.0, 1.0);

    qreal targetRpm = 0.0;
    if (m_gear == QStringLiteral("D") || m_gear == QStringLiteral("R")) {
        const qreal ripple = 55.0 * qSin(elapsedSeconds * 2.4) + 28.0 * qSin(elapsedSeconds * 0.73);
        targetRpm = m_speedKph * profile.rpmPerKph + accelerationLoad * 820.0 + ripple;
        targetRpm = clamp(targetRpm, 0.0, 8200.0);
    }

    m_rpm += (targetRpm - m_rpm) * (1.0 - qExp(-4.5 * dt));
    if (m_rpm < 8.0) {
        m_rpm = 0.0;
    }

    const qreal modeConsumptionOffset = m_driveMode == QStringLiteral("SPORT") ? 1.6
        : m_driveMode == QStringLiteral("ECO") ? -0.5
                                                    : 0.0;
    const qreal percentPerHour = clamp(0.25 + qPow(m_speedKph / 100.0, 2.0) * 10.5
                                           + accelerationLoad * 4.4 + modeConsumptionOffset,
                                       0.18,
                                       22.0);
    m_batteryPercent = clamp(m_batteryPercent - percentPerHour * dt / 3600.0, 5.0, 100.0);

    const qreal aerodynamicPenalty = m_speedKph > 88.0 ? (m_speedKph - 88.0) * 0.0022 : 0.0;
    const qreal efficiencyFactor = clamp(1.0 - aerodynamicPenalty - accelerationLoad * 0.045,
                                         0.72,
                                         1.04);
    m_estimatedRangeKm = m_batteryPercent / 100.0 * profile.fullRangeKm * efficiencyFactor;

    const qreal ambientC = 24.0;
    const qreal motorTargetC = ambientC + 7.0 + m_speedKph * 0.085 + accelerationLoad * 17.0
        + cruiseLoad * 5.0 + (m_driveMode == QStringLiteral("SPORT") ? 3.0 : 0.0);
    const qreal batteryTargetC = ambientC + 5.0 + m_speedKph * 0.034 + percentPerHour * 0.42;

    m_motorTemperatureC += (motorTargetC - m_motorTemperatureC) * (1.0 - qExp(-dt / 17.0));
    m_batteryTemperatureC += (batteryTargetC - m_batteryTemperatureC) * (1.0 - qExp(-dt / 52.0));
    m_odometerKm += m_speedKph * dt / 3600.0;
    m_tripDistanceKm += m_speedKph * dt / 3600.0;

    emitCurrentTelemetry();
}

TelemetrySimulator::ModeProfile TelemetrySimulator::activeProfile() const
{
    if (m_driveMode == QStringLiteral("SPORT")) {
        return {92.0, 126.0, 1.34, 360.0, 48.0};
    }

    if (m_driveMode == QStringLiteral("CITY")) {
        return {68.0, 92.0, 0.96, 405.0, 44.0};
    }

    return {58.0, 78.0, 0.72, 440.0, 40.0};
}

qreal TelemetrySimulator::targetSpeedForTime(qreal seconds) const
{
    if (m_gear == QStringLiteral("P") || m_gear == QStringLiteral("N")) {
        return 0.0;
    }

    const ModeProfile profile = activeProfile();

    if (m_gear == QStringLiteral("R")) {
        return 7.0 + 2.2 * qSin(seconds * 0.85);
    }

    const qreal phase = std::fmod(seconds, 76.0);

    if (phase < 8.0) {
        return lerp(0.0, profile.cruiseSpeedKph, smoothStep(phase / 8.0));
    }

    if (phase < 26.0) {
        return profile.cruiseSpeedKph + 4.5 * qSin(phase * 0.55);
    }

    if (phase < 38.0) {
        return lerp(profile.cruiseSpeedKph, profile.peakSpeedKph, smoothStep((phase - 26.0) / 12.0));
    }

    if (phase < 50.0) {
        return profile.peakSpeedKph - 6.0 + 3.0 * qSin(phase * 0.7);
    }

    if (phase < 62.0) {
        return lerp(profile.peakSpeedKph - 4.0, 24.0, smoothStep((phase - 50.0) / 12.0));
    }

    if (phase < 69.0) {
        return 24.0 + 8.0 * qSin((phase - 62.0) * 0.75);
    }

    return lerp(26.0, 0.0, smoothStep((phase - 69.0) / 7.0));
}

void TelemetrySimulator::emitCurrentTelemetry()
{
    VehicleTelemetry telemetry;
    telemetry.speed = qRound(m_speedKph);
    telemetry.rpm = qRound(m_rpm);
    telemetry.batteryPercent = qRound(m_batteryPercent);
    telemetry.rangeKm = qRound(m_estimatedRangeKm);
    telemetry.motorTemp = qRound(m_motorTemperatureC);
    telemetry.batteryTemp = qRound(m_batteryTemperatureC);
    telemetry.controllerTemp = qRound(m_motorTemperatureC + 3.0);
    telemetry.gearState = m_gear;
    telemetry.driveMode = m_driveMode;
    telemetry.leftIndicator = std::fmod(m_clock.elapsed() / 1000.0, 28.0) > 19.0
        && std::fmod(m_clock.elapsed() / 1000.0, 28.0) < 23.0;
    telemetry.rightIndicator = std::fmod(m_clock.elapsed() / 1000.0, 36.0) > 27.0
        && std::fmod(m_clock.elapsed() / 1000.0, 36.0) < 31.0;
    telemetry.hazardLights = false;
    telemetry.headlights = true;
    telemetry.highBeam = std::fmod(m_clock.elapsed() / 1000.0, 42.0) > 34.0;
    telemetry.charging = false;
    telemetry.batteryVoltage = 385.0F;
    telemetry.batteryCurrent = static_cast<float>(m_speedKph * 0.82);
    telemetry.motorPower = static_cast<float>(m_rpm / 210.0);
    telemetry.regenLevel = m_speedKph < 8.0 ? 1 : 0;
    telemetry.odometer = m_odometerKm;
    telemetry.tripDistance = m_tripDistanceKm;
    telemetry.lowBatteryWarning = telemetry.batteryPercent < 20;
    telemetry.motorOverTempWarning = telemetry.motorTemp > 85;
    telemetry.batteryOverTempWarning = telemetry.batteryTemp > 55;
    telemetry.communicationFault = false;
    telemetry.warningMessage = telemetry.lowBatteryWarning ? QStringLiteral("Low battery")
        : telemetry.motorOverTempWarning ? QStringLiteral("Motor temperature high")
        : telemetry.batteryOverTempWarning ? QStringLiteral("Battery temperature high")
                                           : QString();

    emit telemetryUpdated(telemetry);
}

qreal TelemetrySimulator::clamp(qreal value, qreal minimum, qreal maximum)
{
    return qMax(minimum, qMin(value, maximum));
}

qreal TelemetrySimulator::smoothStep(qreal value)
{
    const qreal t = clamp(value, 0.0, 1.0);
    return t * t * (3.0 - 2.0 * t);
}

qreal TelemetrySimulator::lerp(qreal start, qreal end, qreal amount)
{
    return start + (end - start) * clamp(amount, 0.0, 1.0);
}
