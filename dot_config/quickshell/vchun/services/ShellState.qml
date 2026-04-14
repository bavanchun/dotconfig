pragma Singleton

import QtQuick
import Quickshell

Singleton {
    property bool controlCenterOpen: false
    property bool launcherOpen: false
    property bool calendarOpen: false
    property bool sessionOpen: false
    property bool wallpaperOpen: false
    property bool notificationsOpen: false
    property bool osdOpen: false
    property string osdLabel: "VOL"
    property string osdValue: "0%"

    function closePopups() {
        controlCenterOpen = false;
        launcherOpen = false;
        calendarOpen = false;
        sessionOpen = false;
        wallpaperOpen = false;
        notificationsOpen = false;
    }

    function toggleControlCenter() {
        const next = !controlCenterOpen;
        closePopups();
        controlCenterOpen = next;
    }

    function toggleLauncher() {
        const next = !launcherOpen;
        closePopups();
        launcherOpen = next;
    }

    function toggleCalendar() {
        const next = !calendarOpen;
        closePopups();
        calendarOpen = next;
    }

    function toggleSession() {
        const next = !sessionOpen;
        closePopups();
        sessionOpen = next;
    }

    function toggleWallpaper() {
        const next = !wallpaperOpen;
        closePopups();
        wallpaperOpen = next;
    }

    function toggleNotifications() {
        const next = !notificationsOpen;
        closePopups();
        notificationsOpen = next;
    }

    function showOsd(label, value) {
        osdLabel = label;
        osdValue = value;
        osdOpen = true;
        osdTimer.restart();
    }

    Timer {
        id: osdTimer
        interval: 1200
        onTriggered: osdOpen = false
    }
}
