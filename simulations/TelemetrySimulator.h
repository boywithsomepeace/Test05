#pragma once

#include <QElapsedTimer>
#include <QObject>
#include <QTimer>

#include "models/VehicleTelemetry.h"

class TelemetrySimulator : public QObject
{
    Q_OBJECT

public:
    explicit TelemetrySimulator(QObject *parent = nullptr);

    bool isRunning() const;

public slots:
    void start();
    void stop();
    void setDriveMode(const QString &driveMode);
    void setGear(const QString &gear);

signals:
    void telemetryUpdated(const VehicleTelemetry &telemetry);
    void runningChanged(bool running);

private slots:
    void updateFrame();

private:
    struct ModeProfile
    {
        qreal cruiseSpeedKph;
        qreal peakSpeedKph;
        qreal response;
        qreal fullRangeKm;
        qreal rpmPerKph;
    };

    static qreal clamp(qreal value, qreal minimum, qreal maximum);
    static qreal smoothStep(qreal value);
    static qreal lerp(qreal start, qreal end, qreal amount);

    ModeProfile activeProfile() const;
    qreal targetSpeedForTime(qreal seconds) const;
    void emitCurrentTelemetry();

    QTimer m_timer;
    QElapsedTimer m_clock;
    qint64 m_lastTickMs = 0;

    QString m_driveMode = QStringLiteral("ECO");
    QString m_gear = QStringLiteral("D");

    qreal m_speedKph = 0.0;
    qreal m_rpm = 0.0;
    qreal m_batteryPercent = 82.0;
    qreal m_motorTemperatureC = 32.0;
    qreal m_batteryTemperatureC = 29.0;
    qreal m_odometerKm = 12458.2;
    qreal m_tripDistanceKm = 0.0;
    qreal m_estimatedRangeKm = 332.0;
};
