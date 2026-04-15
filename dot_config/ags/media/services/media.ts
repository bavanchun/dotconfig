import GLib from "gi://GLib?version=2.0"
import AstalMpris from "gi://AstalMpris?version=0.1"

type Player = AstalMpris.Player

export type MediaSnapshot = {
    players: Player[]
    current: Player | null
    title: string
    artist: string
    album: string
    identity: string
    coverArt: string
    position: number
    length: number
    isPlaying: boolean
    canPlay: boolean
    canPause: boolean
    canNext: boolean
    canPrevious: boolean
    canSeek: boolean
}

const IMPORTANT_SIGNALS = [
    "notify::title",
    "notify::artist",
    "notify::album",
    "notify::cover-art",
    "notify::art-url",
    "notify::position",
    "notify::length",
    "notify::playback-status",
    "notify::can-play",
    "notify::can-pause",
    "notify::can-go-next",
    "notify::can-go-previous",
    "notify::can-seek",
]

export function formatTime(seconds: number): string {
    if (!Number.isFinite(seconds) || seconds < 0) return "0:00"

    const h = Math.floor(seconds / 3600)
    const m = Math.floor((seconds % 3600) / 60)
    const s = Math.floor(seconds % 60)
    const pad = (n: number) => n.toString().padStart(2, "0")

    return h > 0 ? `${h}:${pad(m)}:${pad(s)}` : `${m}:${pad(s)}`
}

export class MediaService {
    private mpris = AstalMpris.get_default()
    private selectedPlayer: Player | null = null
    private listeners = new Set<() => void>()
    private playerSignalIds = new Map<Player, number[]>()
    private tickId = 0

    constructor() {
        this.mpris.connect("player-added", () => this.rebindPlayers())
        this.mpris.connect("player-closed", () => this.rebindPlayers())
        this.mpris.connect("notify::players", () => this.rebindPlayers())
        this.rebindPlayers()
    }

    subscribe(listener: () => void): () => void {
        this.listeners.add(listener)
        listener()
        return () => this.listeners.delete(listener)
    }

    setPanelVisible(visible: boolean) {
        if (visible && this.tickId === 0) {
            this.tickId = GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, 1, () => {
                if (this.snapshot().isPlaying) this.emit()
                return GLib.SOURCE_CONTINUE
            })
        } else if (!visible && this.tickId !== 0) {
            GLib.source_remove(this.tickId)
            this.tickId = 0
        }
    }

    snapshot(): MediaSnapshot {
        const players = this.getPlayers()
        const current = this.pickCurrent(players)
        const playbackStatus = current?.playbackStatus

        return {
            players,
            current,
            title: this.clean(current?.title || ""),
            artist: this.clean(current?.artist || ""),
            album: this.clean(current?.album || ""),
            identity: this.clean(current?.identity || current?.entry || ""),
            coverArt: current?.coverArt || "",
            position: this.validNumber(current?.position),
            length: this.validNumber(current?.length),
            isPlaying: playbackStatus === AstalMpris.PlaybackStatus.PLAYING,
            canPlay: !!current?.canPlay,
            canPause: !!current?.canPause,
            canNext: !!current?.canGoNext,
            canPrevious: !!current?.canGoPrevious,
            canSeek: !!current?.canSeek,
        }
    }

    playPause() {
        this.snapshot().current?.play_pause()
    }

    next() {
        this.snapshot().current?.next()
    }

    previous() {
        this.snapshot().current?.previous()
    }

    seekRatio(ratio: number) {
        const snap = this.snapshot()
        if (!snap.current || !snap.canSeek || snap.length <= 0) return
        snap.current.position = Math.max(0, Math.min(1, ratio)) * snap.length
        this.emit()
    }

    cyclePlayer() {
        const players = this.getPlayers()
        if (players.length === 0) {
            this.selectedPlayer = null
            this.emit()
            return
        }

        const current = this.pickCurrent(players)
        const currentIndex = Math.max(0, players.indexOf(current as Player))
        this.selectedPlayer = players[(currentIndex + 1) % players.length]
        this.emit()
    }

    private rebindPlayers() {
        for (const [player, ids] of this.playerSignalIds) {
            for (const id of ids) player.disconnect(id)
        }
        this.playerSignalIds.clear()

        for (const player of this.getPlayers()) {
            const ids = IMPORTANT_SIGNALS.map(signal => player.connect(signal, () => this.emit()))
            this.playerSignalIds.set(player, ids)
        }

        if (this.selectedPlayer && !this.getPlayers().includes(this.selectedPlayer)) {
            this.selectedPlayer = null
        }

        this.emit()
    }

    private getPlayers(): Player[] {
        return (this.mpris.players || []).filter(player => !!player?.canControl || !!player?.canPlay)
    }

    private pickCurrent(players: Player[]): Player | null {
        if (players.length === 0) return null
        if (this.selectedPlayer && players.includes(this.selectedPlayer)) return this.selectedPlayer

        const playing = players.find(player => player.playbackStatus === AstalMpris.PlaybackStatus.PLAYING)
        return playing || players[0]
    }

    private emit() {
        for (const listener of this.listeners) listener()
    }

    private validNumber(value: number | undefined): number {
        return Number.isFinite(value) && value !== undefined && value > 0 ? value : 0
    }

    private clean(value: string): string {
        return value
            .replace(/(\r\n|\n|\r)/g, " ")
            .replace(/\s+[-–—]\s+(YouTube|Google Chrome|Chromium|Mozilla Firefox)$/i, "")
            .replace(/\s+/g, " ")
            .trim()
    }
}

export const mediaService = new MediaService()
