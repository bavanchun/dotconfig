import app from "ags/gtk4/app"
import style from "./style.scss"
import ControlCenter from "./widget/ControlCenter"

app.start({
    instanceName: "control-center",
    css: style,
    main() {
        ControlCenter()
    },
})
