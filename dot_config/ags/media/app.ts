import app from "ags/gtk4/app"
import GLib from "gi://GLib?version=2.0"
import { createMediaPanel } from "./widgets/MediaPanel"

let panel: ReturnType<typeof createMediaPanel> | null = null

function togglePanel(force?: boolean) {
    if (!panel) return
    panel.visible = force ?? !panel.visible
}

app.start({
    instanceName: "media-panel",
    css: `${GLib.getenv("HOME")}/.config/ags/media/style.css`,
    main() {
        panel = createMediaPanel(app)
    },
    requestHandler(argv, response) {
        const command = argv[0] || "toggle"

        if (command === "toggle") {
            togglePanel()
            response("toggled")
        } else if (command === "open") {
            togglePanel(true)
            response("opened")
        } else if (command === "close") {
            togglePanel(false)
            response("closed")
        } else {
            response(`unknown command: ${command}`)
        }
    },
})
