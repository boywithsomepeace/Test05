#pragma once

#include <QHash>
#include <QObject>
#include <QString>
#include <QStringList>

class SettingsManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString language READ language WRITE setLanguage NOTIFY languageChanged)
    Q_PROPERTY(QString unitSystem READ unitSystem WRITE setUnitSystem NOTIFY unitSystemChanged)
    Q_PROPERTY(qreal brightness READ brightness WRITE setBrightness NOTIFY brightnessChanged)
    Q_PROPERTY(qreal contrast READ contrast WRITE setContrast NOTIFY contrastChanged)
    Q_PROPERTY(int revision READ revision NOTIFY languageChanged)

public:
    explicit SettingsManager(QObject *parent = nullptr);

    QString language() const;
    QString unitSystem() const;
    qreal brightness() const;
    qreal contrast() const;
    int revision() const;

    Q_INVOKABLE QString text(const QString &key) const;
    Q_INVOKABLE QStringList supportedLanguages() const;

public slots:
    void setLanguage(const QString &language);
    void setUnitSystem(const QString &unitSystem);
    void setBrightness(qreal brightness);
    void setContrast(qreal contrast);

signals:
    void languageChanged();
    void unitSystemChanged();
    void brightnessChanged();
    void contrastChanged();

private:
    void loadTranslations();
    void loadTranslationFile(const QString &language, const QString &path);
    static qreal clamped(qreal value, qreal minimum, qreal maximum);
    static QString normalizedLanguage(const QString &language);
    static QString normalizedUnitSystem(const QString &unitSystem);

    QString m_language = QStringLiteral("en");
    QString m_unitSystem = QStringLiteral("metric");
    qreal m_brightness = 0.82;
    qreal m_contrast = 0.58;
    int m_revision = 0;
    QHash<QString, QHash<QString, QString>> m_translations;
};
