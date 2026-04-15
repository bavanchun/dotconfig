import Gtk from "gi://Gtk?version=4.0"
import Astal from "gi://Astal?version=4.0"
import Pango from "gi://Pango?version=1.0"
import Gdk from "gi://Gdk?version=4.0"
import { mediaService, formatTime } from "../services/media"

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

function clearBox(box: Gtk.Box) {
    let child = box.get_first_child()
    while (child) {
        const next = child.get_next_sibling()
        box.remove(child)
        child = next
    }
}

function label(text = "", className = "", xalign = 0) {
    const widget = new Gtk.Label({
        label: text,
        xalign,
        ellipsize: Pango.EllipsizeMode.END,
    })
    if (className) widget.add_css_class(className)
    return widget
}

function iconButton(iconName: string, className = "", pixelSize = 18) {
    const image = new Gtk.Image({ icon_name: iconName, pixel_size: pixelSize })
    const button = new Gtk.Button({ child: image })
    button.add_css_class("icon-button")
    if (className) button.add_css_class(className)
    return { button, image }
}

function setPictureFile(picture: Gtk.Picture, path: string) {
    picture.set_filename(path)
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
        width_request: 448,
    }), "media-panel")

    const header = addClass(new Gtk.Box({
        orientation: Gtk.Orientation.HORIZONTAL,
        spacing: 10,
    }), "media-header", "surface-card")

    const headerLead = addClass(new Gtk.Box({
        orientation: Gtk.Orientation.HORIZONTAL,
        spacing: 10,
    }), "header-lead")
    headerLead.hexpand = true

    const headerIcon = new Gtk.Image({ icon_name: "multimedia-player-symbolic", pixel_size: 18 })
    const headingGroup = addClass(new Gtk.Box({
        orientation: Gtk.Orientation.VERTICAL,
        spacing: 2,
    }), "heading-group")
    const heading = label("Media Player", "heading")
    const headingCaption = label("Art-first panel", "heading-caption")

    headingGroup.append(heading)
    headingGroup.append(headingCaption)
    headerLead.append(headerIcon)
    headerLead.append(headingGroup)

    const playerPopover = new Gtk.Popover()
    const playerList = addClass(new Gtk.Box({
        orientation: Gtk.Orientation.VERTICAL,
        spacing: 6,
        margin_top: 8,
        margin_bottom: 8,
        margin_start: 8,
        margin_end: 8,
    }), "player-popover")
    playerPopover.set_child(playerList)

    const playerLabel = label("Player", "player-button-label", 0.5)
    const playerChevron = new Gtk.Image({ icon_name: "pan-down-symbolic", pixel_size: 14 })
    const playerButtonChild = addClass(new Gtk.Box({
        orientation: Gtk.Orientation.HORIZONTAL,
        spacing: 6,
    }), "player-button-content")
    playerButtonChild.append(playerLabel)
    playerButtonChild.append(playerChevron)

    const playerButton = addClass(new Gtk.MenuButton({
        child: playerButtonChild,
        tooltip_text: "Choose active player",
    }), "player-button") as Gtk.MenuButton
    playerButton.set_popover(playerPopover)

    const { button: closeButton } = iconButton("window-close-symbolic")
    closeButton.connect("clicked", () => {
        win.visible = false
    })

    header.append(headerLead)
    header.append(playerButton)
    header.append(closeButton)

    const card = addClass(new Gtk.Overlay(), "media-card", "surface-card")

    const backdrop = addClass(new Gtk.Picture(), "media-backdrop")
    backdrop.set_can_shrink(true)
    backdrop.set_content_fit(Gtk.ContentFit.COVER)
    backdrop.set_size_request(416, 520)

    const scrim = addClass(new Gtk.Box(), "media-scrim")
    const glow = addClass(new Gtk.Box(), "media-glow")

    const content = addClass(new Gtk.Box({
        orientation: Gtk.Orientation.VERTICAL,
        spacing: 16,
        margin_top: 18,
        margin_bottom: 18,
        margin_start: 18,
        margin_end: 18,
    }), "media-card-content")

    const statusRow = addClass(new Gtk.Box({
        orientation: Gtk.Orientation.HORIZONTAL,
        spacing: 8,
        halign: Gtk.Align.CENTER,
    }), "status-row")
    const identityPill = label("No player", "identity-pill", 0.5)
    const statePill = label("Idle", "state-pill", 0.5)
    statusRow.append(identityPill)
    statusRow.append(statePill)

    const artShell = addClass(new Gtk.Overlay(), "art-shell")
    artShell.set_size_request(272, 272)
    artShell.halign = Gtk.Align.CENTER

    const coverPicture = addClass(new Gtk.Picture(), "cover-picture")
    coverPicture.set_can_shrink(true)
    coverPicture.set_content_fit(Gtk.ContentFit.COVER)
    coverPicture.set_size_request(272, 272)

    const coverFallback = addClass(new Gtk.Image({
        icon_name: "media-optical-symbolic",
        pixel_size: 76,
        halign: Gtk.Align.CENTER,
        valign: Gtk.Align.CENTER,
    }), "cover-fallback")

    artShell.set_child(coverPicture)
    artShell.add_overlay(coverFallback)

    const meta = addClass(new Gtk.Box({
        orientation: Gtk.Orientation.VERTICAL,
        spacing: 6,
    }), "meta-block")

    const title = label("No media", "title", 0.5)
    title.set_wrap(false)
    title.set_lines(1)

    const artist = label("Start playback to see controls", "subtitle", 0.5)
    artist.set_wrap(false)
    artist.set_lines(1)

    const album = label("", "album", 0.5)
    album.set_wrap(false)
    album.set_lines(1)

    meta.append(title)
    meta.append(artist)
    meta.append(album)

    const progressBlock = addClass(new Gtk.Box({
        orientation: Gtk.Orientation.VERTICAL,
        spacing: 8,
    }), "progress-block")

    const progress = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0, 1, 0.001)
    progress.draw_value = false
    progress.hexpand = true

    const timeRow = addClass(new Gtk.Box({
        orientation: Gtk.Orientation.HORIZONTAL,
        spacing: 12,
    }), "time-row")
    const position = label("0:00", "time")
    const length = label("0:00", "time", 1)
    position.hexpand = true
    timeRow.append(position)
    timeRow.append(length)

    progressBlock.append(progress)
    progressBlock.append(timeRow)

    const controls = addClass(new Gtk.Box({
        orientation: Gtk.Orientation.HORIZONTAL,
        spacing: 14,
        halign: Gtk.Align.CENTER,
    }), "controls")

    const { button: previous } = iconButton("media-skip-backward-symbolic", "secondary-control")
    const { button: play, image: playImage } = iconButton("media-playback-start-symbolic", "play-button", 22)
    const { button: next } = iconButton("media-skip-forward-symbolic", "secondary-control")

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

    content.append(statusRow)
    content.append(artShell)
    content.append(meta)
    content.append(progressBlock)
    content.append(controls)

    card.set_child(backdrop)
    card.add_overlay(scrim)
    card.add_overlay(glow)
    card.add_overlay(content)

    root.append(header)
    root.append(card)
    win.set_child(root)

    mediaService.subscribe(() => {
        const snap = mediaService.snapshot()
        const hasPlayer = snap.current !== null
        const progressValue = snap.length > 0 ? Math.max(0, Math.min(1, snap.position / snap.length)) : 0

        title.label = hasPlayer ? (snap.title || snap.identity || "Unknown media") : "No media"
        artist.label = hasPlayer ? (snap.artist || snap.identity || "Unknown artist") : "Start playback to see controls"
        album.label = snap.album || ""
        album.visible = snap.album.length > 0

        identityPill.label = snap.identity || "No player"
        statePill.label = hasPlayer ? (snap.isPlaying ? "Playing" : "Paused") : "Idle"

        headingCaption.label = snap.players.length > 1
            ? `${snap.players.length} active players`
            : hasPlayer ? "Focused player" : "Waiting for playback"

        position.label = formatTime(snap.position)
        length.label = formatTime(snap.length)
        progress.sensitive = snap.canSeek && snap.length > 0
        progress.set_value(progressValue)

        previous.sensitive = snap.canPrevious
        play.sensitive = snap.canPlay || snap.canPause
        next.sensitive = snap.canNext
        playImage.icon_name = snap.isPlaying ? "media-playback-pause-symbolic" : "media-playback-start-symbolic"

        const canChoosePlayer = snap.players.length > 1
        playerButton.visible = canChoosePlayer
        playerLabel.label = canChoosePlayer ? (snap.identity || `Players ${snap.players.length}`) : "Player"

        clearBox(playerList)
        for (const player of snap.players) {
            const isActive = player === snap.current
            const itemLabel = addClass(new Gtk.Label({
                label: player.identity || player.entry || "Player",
                xalign: 0,
                ellipsize: Pango.EllipsizeMode.END,
            }), "player-list-label")
            const item = addClass(new Gtk.Button({ child: itemLabel }), "player-list-item")
            if (isActive) item.add_css_class("active")
            item.connect("clicked", () => {
                mediaService.selectPlayer(player)
                playerPopover.popdown()
            })
            playerList.append(item)
        }

        const hasArt = snap.coverArt.length > 0
        coverPicture.visible = hasArt
        backdrop.visible = hasArt
        coverFallback.visible = !hasArt
        setClass(card, "with-art", hasArt)

        if (hasArt) {
            try {
                setPictureFile(coverPicture, snap.coverArt)
                setPictureFile(backdrop, snap.coverArt)
            } catch {
                coverPicture.visible = false
                backdrop.visible = false
                coverFallback.visible = true
                card.remove_css_class("with-art")
            }
        }

        if (!hasArt) {
            coverPicture.set_paintable(null)
            backdrop.set_paintable(null)
        }
    })

    win.connect("notify::visible", () => {
        mediaService.setPanelVisible(win.visible)
    })

    return win
}
