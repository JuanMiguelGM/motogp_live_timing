import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { interval: { type: Number, default: 30 } }

  connect() {
    this.timer = setInterval(() => this.checkStatus(), this.intervalValue * 1000)
  }

  disconnect() {
    if (this.timer) clearInterval(this.timer)
  }

  async checkStatus() {
    try {
      const response = await fetch("/api/session_status")
      if (!response.ok) return

      const data = await response.json()
      if (data.live) {
        clearInterval(this.timer)
        window.location.reload()
      }
    } catch {
      // silently ignore fetch errors
    }
  }
}
