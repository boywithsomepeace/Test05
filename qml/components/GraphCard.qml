import QtQuick
import EvHmi

BaseCard {
    id: root

    property var samples: []
    property real minimumValue: 0
    property real maximumValue: 100
    property color lineColor: Colors.accentPrimary
    property string unit: ""
    property string currentText: ""

    padding: Math.round(12 * Theme.scale)

    onSamplesChanged: graph.requestPaint()
    onMinimumValueChanged: graph.requestPaint()
    onMaximumValueChanged: graph.requestPaint()
    onLineColorChanged: graph.requestPaint()
    onWidthChanged: graph.requestPaint()
    onHeightChanged: graph.requestPaint()

    Text {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: root.padding
        text: root.currentText
        color: Colors.textPrimary
        font.family: Typography.family
        font.pixelSize: Typography.bodySmall
        font.weight: Font.DemiBold
    }

    Canvas {
        id: graph
        anchors.fill: parent
        anchors.leftMargin: root.padding
        anchors.rightMargin: root.padding
        anchors.topMargin: Math.round(38 * Theme.scale)
        anchors.bottomMargin: Math.round(20 * Theme.scale)
        antialiasing: true

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            var span = Math.max(1, root.maximumValue - root.minimumValue)
            var bottom = height - 2
            var top = 4
            var graphHeight = bottom - top

            ctx.lineWidth = Math.max(1, 1 * Theme.scale)
            ctx.strokeStyle = Colors.gridLine
            for (var g = 0; g < 4; ++g) {
                var y = top + graphHeight * g / 3
                ctx.beginPath()
                ctx.moveTo(0, y)
                ctx.lineTo(width, y)
                ctx.stroke()
            }

            if (!root.samples || root.samples.length < 2) {
                return
            }

            ctx.lineWidth = Math.max(2, 2 * Theme.scale)
            ctx.lineJoin = "round"
            ctx.lineCap = "round"
            ctx.strokeStyle = root.lineColor
            ctx.beginPath()

            for (var i = 0; i < root.samples.length; ++i) {
                var value = Math.max(root.minimumValue, Math.min(root.maximumValue, root.samples[i]))
                var x = width * i / (root.samples.length - 1)
                var yValue = bottom - ((value - root.minimumValue) / span) * graphHeight
                if (i === 0) {
                    ctx.moveTo(x, yValue)
                } else {
                    ctx.lineTo(x, yValue)
                }
            }
            ctx.stroke()
        }
    }

    Text {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: root.padding
        text: root.unit
        color: Colors.textMuted
        font.family: Typography.family
        font.pixelSize: Typography.label
        font.weight: Font.Medium
    }
}
