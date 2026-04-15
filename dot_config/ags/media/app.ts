import app from "ags/gtk4/app"
import GLib from "gi://GLib?version=2.0"
import { createMediaPanel } from "./widgets/MediaPanel"
import { createMediaMini } from "./widgets/MediaMini"
import { mediaService } from "./services/media"

let panel: ReturnType<typeof createMediaPanel> | null = null
let mini: ReturnType<typeof createMediaMini> | null = null

function togglePanel(force?: boolean) {
    if (!panel) return
    panel.visible = force ?? !panel.visible
}

function mediaStatus() {
    const snap = mediaService.snapshot()
    return JSON.stringify({
        hasPlayer: snap.current !== null,
        title: snap.title,
        artist: snap.artist,
        album: snap.album,
        identity: snap.identity,
        players: snap.players.map(player => ({
            identity: player.identity || player.entry || "Player",
        })),
        playersCount: snap.players.length,
        isPlaying: snap.isPlaying,
        position: snap.position,
        length: snap.length,
    })
}

app.start({
    instanceName: "media-panel",
    css: `${GLib.getenv("HOME")}/.config/ags/media/style.css`,
    main() {
        panel = createMediaPanel(app)
        mini = createMediaMini(app, () => togglePanel(true))
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
        } else if (command === "status") {
            response(mediaStatus())
        } else if (command === "play-pause") {
            mediaService.playPause()
            response("ok")
        } else if (command === "next") {
            mediaService.next()
            response("ok")
        } else if (command === "previous") {
            mediaService.previous()
            response("ok")
        } else if (command === "next-player") {
            mediaService.cyclePlayer()
            response("ok")
        } else {
            response(`unknown command: ${command}`)
        }
    },
})
