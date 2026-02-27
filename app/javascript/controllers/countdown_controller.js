import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "days", "hours", "minutes", "seconds"]
  static values = { target: String }

  connect() {
    if (!this.targetValue) return

    this.deadline = new Date(this.targetValue)
    this.update()
    this.timer = setInterval(() => this.update(), 1000)
  }

  disconnect() {
    if (this.timer) clearInterval(this.timer)
  }

  update() {
    const now = new Date()
    const diff = this.deadline - now

    if (diff <= 0) {
      this.daysTarget.textContent = "0"
      this.hoursTarget.textContent = "0"
      this.minutesTarget.textContent = "0"
      this.secondsTarget.textContent = "0"
      clearInterval(this.timer)
      return
    }

    const days = Math.floor(diff / (1000 * 60 * 60 * 24))
    const hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60))
    const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60))
    const seconds = Math.floor((diff % (1000 * 60)) / 1000)

    this.daysTarget.textContent = days
    this.hoursTarget.textContent = String(hours).padStart(2, "0")
    this.minutesTarget.textContent = String(minutes).padStart(2, "0")
    this.secondsTarget.textContent = String(seconds).padStart(2, "0")
  }
}
