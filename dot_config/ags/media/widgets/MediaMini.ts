import Gtk from "gi://Gtk?version=4.0"
import Astal from "gi://Astal?version=4.0"
import Gdk from "gi://Gdk?version=4.0"
import Pango from "gi://Pango?version=1.0"
import { mediaService } from "../services/media"

function addClass<T extends Gtk.Widget>(widget: T, ...classNames: string[]) {
    for (const className of classNames) {
        if (className) widget.add_css_class(className)
    }
    return widget
}

function setClass(widget: Gtk.Widget, className: string, enabled: boolean) {
    if (enabled) widget.add_css_class(className)
    else widget.remove_css_class(className)
}

function label(className: string, xalign = 0) {
    const widget = new Gtk.Label({
        xalign,
        ellipsize: Pango.EllipsizeMode.END,
    })
    widget.add_css_class(className)
    return widget
}

export function createMediaMini(app: Gtk.Application, openPanel: () => void) {
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
        name: "media-mini",
        namespace: "ags-media-mini",
        layer: Astal.Layer.OVERLAY,
        keymode: Astal.Keymode.ON_DEMAND,
        anchor: Astal.WindowAnchor.TOP | Astal.WindowAnchor.LEFT,
        margin_top: 12,
        margin_left: 742,
        visible: false,
        ...(laptopMonitor ? { gdkmonitor: laptopMonitor } : {}),
    })

    const shell = addClass(new Gtk.Box({
        orientation: Gtk.Orientation.HORIZONTAL,
    }), "media-mini-shell")

    const capsule = addClass(new Gtk.Box({
        orientation: Gtk.Orientation.HORIZONTAL,
        spacing: 10,
        margin_top: 6,
        margin_bottom: 6,
        margin_start: 12,
        margin_end: 12,
    }), "media-mini")
    capsule.set_size_request(292, 0)

    const art = addClass(new Gtk.Picture(), "media-mini-art")
    art.set_can_shrink(true)
    art.set_content_fit(Gtk.ContentFit.COVER)
    art.set_size_request(30, 30)

    const artFallback = addClass(new Gtk.Image({
        icon_name: "media-optical-symbolic",
        pixel_size: 16,
    }), "media-mini-fallback")

    const artFrame = addClass(new Gtk.Overlay(), "media-mini-art-frame")
    artFrame.set_child(art)
    artFrame.add_overlay(artFallback)

    const textBox = addClass(new Gtk.Box({
        orientation: Gtk.Orientation.VERTICAL,
        spacing: 1,
    }), "media-mini-text")
    textBox.hexpand = true

    const title = label("media-mini-title")
    const subtitle = label("media-mini-subtitle")
    textBox.append(title)
    textBox.append(subtitle)

    const state = label("media-mini-state", 0.5)

    capsule.append(artFrame)
    capsule.append(textBox)
    capsule.append(state)
    shell.append(capsule)
    win.set_child(shell)

    const motion = new Gtk.EventControllerMotion()
    motion.connect("enter", () => capsule.add_css_class("hover"))
    motion.connect("leave", () => capsule.remove_css_class("hover"))
    capsule.add_controller(motion)

    const click = new Gtk.GestureClick()
    click.set_button(0)
    click.connect("pressed", (_gesture, _nPress, _x, _y) => {
        const button = click.get_current_button()
        if (button === Gdk.BUTTON_PRIMARY) {
            openPanel()
        } else if (button === Gdk.BUTTON_MIDDLE) {
            mediaService.cyclePlayer()
        } else if (button === Gdk.BUTTON_SECONDARY) {
            mediaService.playPause()
        }
    })
    capsule.add_controller(click)

    mediaService.subscribe(() => {
        const snap = mediaService.snapshot()
        const hasPlayer = snap.current !== null

        win.visible = hasPlayer
        if (!hasPlayer) return

        title.label = snap.title || snap.identity || "Unknown media"
        subtitle.label = snap.artist || snap.album || snap.identity || "Ready"
        state.label = snap.isPlaying ? "󰎆" : "󰏤"
        setClass(capsule, "playing", snap.isPlaying)
        setClass(capsule, "paused", !snap.isPlaying)
        setClass(capsule, "multi-player", snap.players.length > 1)

        const hasArt = snap.coverArt.length > 0
        art.visible = hasArt
        artFallback.visible = !hasArt

        if (hasArt) {
            try {
                art.set_filename(snap.coverArt)
            } catch {
                art.visible = false
                artFallback.visible = true
            }
        } else {
            art.set_paintable(null)
        }
    })

    return win
}
