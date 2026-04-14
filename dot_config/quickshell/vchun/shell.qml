//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import Quickshell
import Quickshell.Io
import "modules/controlcenter"
import "modules/launcher"
import "modules/osd"
import "modules/popups"
import "modules/session"
import "modules/bar"
import "services"

ShellRoot {
    Bar {}
    ControlCenter {}
    Launcher {}
    Osd {}
    CalendarMediaPopup {}
    SessionMenu {}

    IpcHandler {
        target: "shell"

        function control(): void { ShellState.toggleControlCenter() }
        function launcher(): void { ShellState.toggleLauncher() }
        function calendar(): void { ShellState.toggleCalendar() }
        function session(): void { ShellState.toggleSession() }
        function close(): void { ShellState.closePopups() }
        function reloadTheme(): void { Quickshell.reload(false) }
    }
}
