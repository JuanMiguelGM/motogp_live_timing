import { Controller } from "@hotwired/stimulus"

const FLAG_STYLES = {
  GREEN:           { bg: "bg-green-600",  text: "text-white",    label: "GREEN FLAG" },
  YELLOW:          { bg: "bg-yellow-600", text: "text-white",    label: "YELLOW FLAG" },
  "DOUBLE YELLOW": { bg: "bg-yellow-600", text: "text-white",    label: "DOUBLE YELLOW" },
  RED:             { bg: "bg-red-500",    text: "text-white",    label: "RED FLAG" },
  CHEQUERED:       { bg: "bg-white",      text: "text-gray-950", label: "CHEQUERED FLAG" },
  BLUE:            { bg: "bg-blue-400",   text: "text-white",    label: "BLUE FLAG" },
  "BLACK AND WHITE": { bg: "bg-gray-600", text: "text-white",   label: "BLACK AND WHITE FLAG" },
  CLEAR:           { bg: "bg-green-600",  text: "text-white",    label: "TRACK CLEAR" }
}

export default class extends Controller {
  static targets = ["banner", "text"]

  updateFlag(flag) {
    if (!flag || flag === "GREEN") {
      this.bannerTarget.classList.add("hidden")
      return
    }

    const style = FLAG_STYLES[flag] || { bg: "bg-gray-700", text: "text-white", label: flag }

    // Remove old bg/text classes
    this.bannerTarget.className = this.bannerTarget.className
      .replace(/bg-\S+/g, "")
      .replace(/text-\S+/g, "")

    this.bannerTarget.classList.add(style.bg, style.text)
    this.bannerTarget.classList.remove("hidden")
    this.textTarget.textContent = style.label
  }
}
