pragma Singleton

import QtQuick

QtObject {
    property real scale: 1.0

    readonly property string family: "Inter"

    readonly property int displayLarge: Math.round(88 * scale)
    readonly property int displayMedium: Math.round(52 * scale)
    readonly property int displaySmall: Math.round(38 * scale)
    readonly property int titleLarge: Math.round(26 * scale)
    readonly property int titleMedium: Math.round(20 * scale)
    readonly property int bodyLarge: Math.round(18 * scale)
    readonly property int bodyMedium: Math.round(15 * scale)
    readonly property int bodySmall: Math.round(13 * scale)
    readonly property int label: Math.round(12 * scale)
}
