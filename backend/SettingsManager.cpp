#include "backend/SettingsManager.h"

#include <QFile>
#include <QXmlStreamReader>

SettingsManager::SettingsManager(QObject *parent)
    : QObject(parent)
{
    loadTranslations();
}

QString SettingsManager::language() const { return m_language; }
QString SettingsManager::unitSystem() const { return m_unitSystem; }
qreal SettingsManager::brightness() const { return m_brightness; }
qreal SettingsManager::contrast() const { return m_contrast; }
int SettingsManager::revision() const { return m_revision; }

QString SettingsManager::text(const QString &key) const
{
    if (m_language == QStringLiteral("en")) {
        return key;
    }

    const auto languageIt = m_translations.constFind(m_language);
    if (languageIt == m_translations.constEnd()) {
        return key;
    }

    const QString translated = languageIt.value().value(key);
    return translated.isEmpty() ? key : translated;
}

QStringList SettingsManager::supportedLanguages() const
{
    return {QStringLiteral("en"), QStringLiteral("de"), QStringLiteral("es")};
}

void SettingsManager::setLanguage(const QString &language)
{
    const QString normalized = normalizedLanguage(language);
    if (normalized.isEmpty() || normalized == m_language) {
        return;
    }

    m_language = normalized;
    ++m_revision;
    emit languageChanged();
}

void SettingsManager::setUnitSystem(const QString &unitSystem)
{
    const QString normalized = normalizedUnitSystem(unitSystem);
    if (normalized.isEmpty() || normalized == m_unitSystem) {
        return;
    }

    m_unitSystem = normalized;
    emit unitSystemChanged();
}

void SettingsManager::setBrightness(qreal brightness)
{
    const qreal value = clamped(brightness, 0.3, 1.0);
    if (qAbs(value - m_brightness) < 0.001) {
        return;
    }

    m_brightness = value;
    emit brightnessChanged();
}

void SettingsManager::setContrast(qreal contrast)
{
    const qreal value = clamped(contrast, 0.0, 1.0);
    if (qAbs(value - m_contrast) < 0.001) {
        return;
    }

    m_contrast = value;
    emit contrastChanged();
}

void SettingsManager::loadTranslations()
{
    loadTranslationFile(QStringLiteral("de"), QStringLiteral(":/i18n/ev_hmi_de.ts"));
    loadTranslationFile(QStringLiteral("es"), QStringLiteral(":/i18n/ev_hmi_es.ts"));
}

void SettingsManager::loadTranslationFile(const QString &language, const QString &path)
{
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        return;
    }

    QXmlStreamReader xml(&file);
    QString source;
    QHash<QString, QString> messages;

    while (!xml.atEnd()) {
        xml.readNext();

        if (!xml.isStartElement()) {
            continue;
        }

        if (xml.name() == QLatin1String("source")) {
            source = xml.readElementText();
        } else if (xml.name() == QLatin1String("translation") && !source.isEmpty()) {
            const QString translation = xml.readElementText();
            if (!translation.isEmpty()) {
                messages.insert(source, translation);
            }
            source.clear();
        }
    }

    if (!messages.isEmpty()) {
        m_translations.insert(language, messages);
    }
}

qreal SettingsManager::clamped(qreal value, qreal minimum, qreal maximum)
{
    return qMax(minimum, qMin(value, maximum));
}

QString SettingsManager::normalizedLanguage(const QString &language)
{
    const QString value = language.trimmed().toLower();
    if (value == QStringLiteral("en") || value == QStringLiteral("english")) {
        return QStringLiteral("en");
    }
    if (value == QStringLiteral("de") || value == QStringLiteral("german")) {
        return QStringLiteral("de");
    }
    if (value == QStringLiteral("es") || value == QStringLiteral("spanish")) {
        return QStringLiteral("es");
    }
    return QString();
}

QString SettingsManager::normalizedUnitSystem(const QString &unitSystem)
{
    const QString value = unitSystem.trimmed().toLower();
    if (value == QStringLiteral("metric") || value == QStringLiteral("km")) {
        return QStringLiteral("metric");
    }
    if (value == QStringLiteral("imperial") || value == QStringLiteral("mi")) {
        return QStringLiteral("imperial");
    }
    return QString();
}
