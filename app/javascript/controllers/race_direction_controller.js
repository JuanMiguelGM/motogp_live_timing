import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["feed", "toggleBtn"]

  toggle() {
    const isHidden = this.feedTarget.classList.toggle("hidden")
    this.toggleBtnTarget.textContent = isHidden ? "Show" : "Hide"
  }

  addMessage(msg) {
    const el = document.createElement("div")
    el.className = "flex items-start gap-2 py-0.5 text-xs race-direction-msg"

    const time = msg.recorded_at ? new Date(msg.recorded_at).toLocaleTimeString("en-GB") : ""
    const flagClass = this.flagColorClass(msg.flag)
    const flagHtml = msg.flag ? `<span class="font-bold shrink-0 ${flagClass}">${msg.flag}</span>` : ""

    el.innerHTML = `
      <span class="text-gray-600 whitespace-nowrap shrink-0">${time}</span>
      ${flagHtml}
      <span class="text-gray-300">${msg.message}</span>
    `

    this.feedTarget.prepend(el)

    // Keep only 30 messages
    const msgs = this.feedTarget.querySelectorAll(".race-direction-msg")
    if (msgs.length > 30) msgs[msgs.length - 1].remove()
  }

  flagColorClass(flag) {
    const colors = {
      GREEN: "text-green-400",
      YELLOW: "text-yellow-400",
      "DOUBLE YELLOW": "text-yellow-400",
      RED: "text-red-500",
      CHEQUERED: "text-white",
      BLUE: "text-blue-400",
      "BLACK AND WHITE": "text-gray-300"
    }
    return colors[flag] || "text-gray-400"
  }
}
