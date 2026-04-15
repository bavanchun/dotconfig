import Gtk from "gi://Gtk?version=4.0"
import Astal from "gi://Astal?version=4.0"
import Pango from "gi://Pango?version=1.0"
import Gdk from "gi://Gdk?version=4.0"
import { mediaService, formatTime } from "../services/media"

function addClass(widget: Gtk.Widget, className: string) {
    widget.add_css_class(className)
    return widget
}

function label(text = "", className = "") {
    const widget = new Gtk.Label({
        label: text,
        xalign: 0,
        ellipsize: Pango.EllipsizeMode.END,
    })
    if (className) widget.add_css_class(className)
    return widget
}

function iconButton(iconName: string, className = "") {
    const image = new Gtk.Image({ icon_name: iconName, pixel_size: 18 })
    const button = new Gtk.Button({ child: image })
    button.add_css_class("icon-button")
    if (className) button.add_css_class(className)
    return button
}

export function createMediaPanel(app: Gtk.Application) {
    const display = Gdk.Display.get_default()
    const monitors = display?.get_monitors()
    let laptopMonitor: Gdk.Monitor | null = null

    if (monitors) {
        for (let i = 0; i < monitors.get_n_items(); i++) {
            const monitor = monitors.get_item(i) as Gdk.Monitor | null
            if (monitor?.get_connector() === "eDP-1") {
                laptopMonitor = monitor
                break
            }
        }
    }

    const win = new Astal.Window({
        application: app,
        name: "media-panel",
        namespace: "ags-media-panel",
        layer: Astal.Layer.OVERLAY,
        keymode: Astal.Keymode.ON_DEMAND,
        anchor: Astal.WindowAnchor.TOP | Astal.WindowAnchor.LEFT,
        margin_top: 64,
        margin_left: 24,
        visible: false,
        ...(laptopMonitor ? { gdkmonitor: laptopMonitor } : {}),
    })

    const root = addClass(new Gtk.Box({
        orientation: Gtk.Orientation.VERTICAL,
        spacing: 14,
        width_request: 380,
    }), "media-panel")

    const header = addClass(new Gtk.Box({
        orientation: Gtk.Orientation.HORIZONTAL,
        spacing: 10,
    }), "media-header")

    const headerIcon = new Gtk.Image({ icon_name: "multimedia-player-symbolic", pixel_size: 18 })
    const heading = label("Media", "heading")
    heading.hexpand = true

    const playerButton = addClass(new Gtk.Button({ label: "Player" }), "player-button") as Gtk.Button
    playerButton.connect("clicked", () => mediaService.cyclePlayer())

    const closeButton = iconButton("window-close-symbolic")
    closeButton.connect("clicked", () => {
        win.visible = false
    })

    header.append(headerIcon)
    header.append(heading)
    header.append(playerButton)
    header.append(closeButton)

    const content = addClass(new Gtk.Box({
        orientation: Gtk.Orientation.HORIZONTAL,
        spacing: 16,
    }), "media-content")

    const coverFrame = addClass(new Gtk.Box(), "cover-frame")
    coverFrame.set_size_request(112, 112)
    const cover = new Gtk.Image({ icon_name: "media-optical-symbolic", pixel_size: 58 })
    cover.hexpand = true
    cover.vexpand = true
    coverFrame.append(cover)

    const details = new Gtk.Box({
        orientation: Gtk.Orientation.VERTICAL,
        spacing: 8,
    })
    details.hexpand = true

    const title = label("No media", "title")
    const artist = label("Start playback to see controls", "subtitle")
    const album = label("", "album")

    const progress = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0, 1, 0.001)
    progress.draw_value = false
    progress.hexpand = true

    const timeRow = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL })
    const position = label("0:00", "time")
    const length = label("0:00", "time")
    position.hexpand = true
    length.xalign = 1
    timeRow.append(position)
    timeRow.append(length)

    const controls = addClass(new Gtk.Box({
        orientation: Gtk.Orientation.HORIZONTAL,
        spacing: 10,
        halign: Gtk.Align.CENTER,
    }), "controls")

    const previous = iconButton("media-skip-backward-symbolic")
    const play = iconButton("media-playback-start-symbolic", "play-button")
    const next = iconButton("media-skip-forward-symbolic")

    previous.connect("clicked", () => mediaService.previous())
    play.connect("clicked", () => mediaService.playPause())
    next.connect("clicked", () => mediaService.next())
    progress.connect("change-value", (_scale, _scroll, value) => {
        mediaService.seekRatio(value)
        return false
    })

    controls.append(previous)
    controls.append(play)
    controls.append(next)

    details.append(title)
    details.append(artist)
    details.append(album)
    details.append(progress)
    details.append(timeRow)
    details.append(controls)

    content.append(coverFrame)
    content.append(details)

    root.append(header)
    root.append(content)
    win.set_child(root)

    mediaService.subscribe(() => {
        const snap = mediaService.snapshot()
        const hasPlayer = snap.current !== null
        const progressValue = snap.length > 0 ? Math.max(0, Math.min(1, snap.position / snap.length)) : 0

        title.label = hasPlayer ? (snap.title || snap.identity || "Unknown media") : "No media"
        artist.label = hasPlayer ? (snap.artist || snap.identity || "Unknown artist") : "Start playback to see controls"
        album.label = snap.album || ""
        album.visible = snap.album.length > 0
        position.label = formatTime(snap.position)
        length.label = formatTime(snap.length)
        progress.sensitive = snap.canSeek && snap.length > 0
        progress.set_value(progressValue)
        previous.sensitive = snap.canPrevious
        play.sensitive = snap.canPlay || snap.canPause
        next.sensitive = snap.canNext
        playerButton.visible = snap.players.length > 1
        playerButton.label = snap.players.length > 1 ? `${snap.identity || "Player"} (${snap.players.length})` : "Player"

        const playImage = play.child as Gtk.Image
        playImage.icon_name = snap.isPlaying ? "media-playback-pause-symbolic" : "media-playback-start-symbolic"

        if (snap.coverArt) {
            try {
                cover.set_from_file(snap.coverArt)
                cover.pixel_size = 112
            } catch {
                cover.icon_name = "media-optical-symbolic"
                cover.pixel_size = 58
            }
        } else {
            cover.icon_name = "media-optical-symbolic"
            cover.pixel_size = 58
        }
    })

    win.connect("notify::visible", () => {
        mediaService.setPanelVisible(win.visible)
    })

    return win
}
