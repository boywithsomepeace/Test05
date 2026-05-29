import QtQuick
import EvHmi

Item {
    id: root

    property color lineColor: Colors.accentCopper
    property color dimLineColor: Colors.accentCopperDim

    Canvas {
        id: frameCanvas
        anchors.fill: parent
        antialiasing: true

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.clearRect(0, 0, width, height)

            var w = width
            var h = height
            var midY = h * 0.50
            var topY = h * 0.19
            var lowY = h * 0.89
            var notchY = h * 0.30
            var leftInset = w * 0.035
            var rightInset = w * 0.965

            ctx.lineCap = "round"
            ctx.lineJoin = "round"

            ctx.strokeStyle = root.lineColor
            ctx.globalAlpha = 0.72
            ctx.lineWidth = Math.max(2, 3 * Theme.scale)
            ctx.beginPath()
            ctx.moveTo(leftInset, midY)
            ctx.lineTo(w * 0.17, topY)
            ctx.lineTo(w * 0.33, topY - h * 0.04)
            ctx.lineTo(w * 0.41, notchY)
            ctx.lineTo(w * 0.59, notchY)
            ctx.lineTo(w * 0.67, topY - h * 0.04)
            ctx.lineTo(w * 0.83, topY)
            ctx.lineTo(rightInset, midY)
            ctx.lineTo(w * 0.88, lowY)
            ctx.lineTo(w * 0.12, lowY)
            ctx.closePath()
            ctx.stroke()

            ctx.globalAlpha = 0.30
            ctx.lineWidth = Math.max(1, 1.2 * Theme.scale)
            for (var i = 0; i < 16; ++i) {
                var t = i / 15
                var offset = (t - 0.5) * h * 0.26

                ctx.beginPath()
                ctx.moveTo(w * 0.22, midY + offset)
                ctx.lineTo(w * 0.42, midY + offset * 0.18)
                ctx.stroke()

                ctx.beginPath()
                ctx.moveTo(w * 0.78, midY + offset)
                ctx.lineTo(w * 0.58, midY + offset * 0.18)
                ctx.stroke()
            }

            ctx.globalAlpha = 0.26
            ctx.strokeStyle = root.dimLineColor
            ctx.beginPath()
            ctx.moveTo(w * 0.18, h * 0.79)
            ctx.lineTo(w * 0.43, h * 0.79)
            ctx.lineTo(w * 0.47, h * 0.76)
            ctx.lineTo(w * 0.53, h * 0.76)
            ctx.lineTo(w * 0.57, h * 0.79)
            ctx.lineTo(w * 0.82, h * 0.79)
            ctx.stroke()
        }

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        Connections {
            target: Theme
            function onScaleChanged() {
                frameCanvas.requestPaint()
            }
        }
    }
}
