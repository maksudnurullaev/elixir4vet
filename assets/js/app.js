// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//
// If you have dependencies that try to import CSS, esbuild will generate a separate `app.css` file.
// To load it, simply add a second `<link>` to your `root.html.heex` file.

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import { hooks as colocatedHooks } from "phoenix-colocated/elixir4vet"
import topbar from "../vendor/topbar"

const PhoneMask = {
  PREFIX: "+998 (",

  getDigits(value) {
    let digits = value.replace(/\D/g, "")
    if (digits.startsWith("998")) digits = digits.slice(3)
    return digits.slice(0, 9)
  },

  format(digits) {
    if (digits.length === 0) return this.PREFIX
    let result = this.PREFIX
    if (digits.length <= 2) {
      result += digits
    } else {
      result += digits.slice(0, 2) + ") "
      if (digits.length <= 5) {
        result += digits.slice(2)
      } else {
        result += digits.slice(2, 5) + "-"
        if (digits.length <= 7) {
          result += digits.slice(5)
        } else {
          result += digits.slice(5, 7) + "-" + digits.slice(7)
        }
      }
    }
    return result
  },

  mounted() {
    if (!this.el.value) this.el.value = this.PREFIX

    this.el.addEventListener("input", () => {
      const digits = this.getDigits(this.el.value)
      this.el.value = this.format(digits)
    })

    this.el.addEventListener("keydown", (e) => {
      if (e.key === "Backspace" &&
          this.el.selectionStart <= this.PREFIX.length &&
          this.el.selectionEnd <= this.PREFIX.length) {
        e.preventDefault()
      }
    })

    this.el.addEventListener("focus", () => {
      if (!this.el.value || this.el.value.length < this.PREFIX.length) {
        this.el.value = this.PREFIX
      }
      setTimeout(() => this.el.setSelectionRange(this.el.value.length, this.el.value.length), 0)
    })

    this.el.addEventListener("click", () => {
      if (this.el.selectionStart < this.PREFIX.length) {
        this.el.setSelectionRange(this.PREFIX.length, this.PREFIX.length)
      }
    })
  }
}

const WebcamCapture = {
  RESOLUTIONS: {
    "480p":  { width: { ideal: 854  }, height: { ideal: 480  } },
    "720p":  { width: { ideal: 1280 }, height: { ideal: 720  } },
    "1080p": { width: { ideal: 1920 }, height: { ideal: 1080 } },
  },

  async startCamera() {
    if (this.stream) {
      this.stream.getTracks().forEach(t => t.stop())
      this.stream = null
    }
    const res = this.RESOLUTIONS[this.resSelect.value] || this.RESOLUTIONS["720p"]
    this.stream = await navigator.mediaDevices.getUserMedia({
      video: { facingMode: { ideal: this.facingMode }, ...res }
    })
    this.video.srcObject = this.stream
    await this.video.play()
  },

  mounted() {
    this.stream = null
    this.facingMode = "environment"

    const modal = document.getElementById("webcam-modal")
    this.video = document.getElementById("webcam-video")
    this.resSelect = document.getElementById("webcam-resolution")

    modal.addEventListener("close", () => {
      if (this.stream) {
        this.stream.getTracks().forEach(t => t.stop())
        this.stream = null
      }
    })

    this.el.addEventListener("click", async () => {
      try {
        await this.startCamera()
        modal.showModal()
      } catch (_e) {
        alert("Camera access denied or not available.")
      }
    })

    document.getElementById("webcam-flip-btn").addEventListener("click", async () => {
      this.facingMode = this.facingMode === "environment" ? "user" : "environment"
      if (this.stream) await this.startCamera()
    })

    this.resSelect.addEventListener("change", async () => {
      if (this.stream) await this.startCamera()
    })

    document.getElementById("webcam-capture-btn").addEventListener("click", () => {
      const canvas = document.createElement("canvas")
      canvas.width = this.video.videoWidth
      canvas.height = this.video.videoHeight
      canvas.getContext("2d").drawImage(this.video, 0, 0)
      const dataUrl = canvas.toDataURL("image/jpeg", 0.9)
      this.pushEvent("webcam_capture", { data: dataUrl })
      modal.close()
    })

    document.getElementById("webcam-close-btn").addEventListener("click", () => {
      modal.close()
    })
  },

  destroyed() {
    if (this.stream) {
      this.stream.getTracks().forEach(t => t.stop())
    }
  }
}

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
const liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
  hooks: { ...colocatedHooks, PhoneMask, WebcamCapture },
})

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

// Auto-close details/summary menus on mouse leave
window.addEventListener("mouseover", (e) => {
  const details = e.target.closest("details.submenu-details");
  if (details) {
    // If we re-enter the element, cancel any pending close action
    if (details.dataset.timeoutId) {
      clearTimeout(parseInt(details.dataset.timeoutId));
      delete details.dataset.timeoutId;
    }
    if (!details.hasAttribute("open")) {
      details.setAttribute("open", "true");
    }
  }
});

window.addEventListener("mouseout", (e) => {
  const details = e.target.closest("details.submenu-details");
  if (details) {
    const relatedTarget = e.relatedTarget;
    // Only schedule close if we are truly leaving the element tree
    if (!details.contains(relatedTarget)) {
      // Add delay to allow user to bridge gaps or move cursor intentionally
      const timeoutId = setTimeout(() => {
        details.removeAttribute("open");
        delete details.dataset.timeoutId;
      }, 500);
      details.dataset.timeoutId = timeoutId.toString();
    }
  }
});

// The lines below enable quality of life phoenix_live_reload
// development features:
//
//     1. stream server logs to the browser console
//     2. click on elements to jump to their definitions in your code editor
//
if (process.env.NODE_ENV === "development") {
  window.addEventListener("phx:live_reload:attached", ({ detail: reloader }) => {
    // Enable server log streaming to client.
    // Disable with reloader.disableServerLogs()
    reloader.enableServerLogs()

    // Open configured PLUG_EDITOR at file:line of the clicked element's HEEx component
    //
    //   * click with "c" key pressed to open at caller location
    //   * click with "d" key pressed to open at function component definition location
    let keyDown
    window.addEventListener("keydown", e => keyDown = e.key)
    window.addEventListener("keyup", _e => keyDown = null)
    window.addEventListener("click", e => {
      if (keyDown === "c") {
        e.preventDefault()
        e.stopImmediatePropagation()
        reloader.openEditorAtCaller(e.target)
      } else if (keyDown === "d") {
        e.preventDefault()
        e.stopImmediatePropagation()
        reloader.openEditorAtDef(e.target)
      }
    }, true)

    window.liveReloader = reloader
  })
}

