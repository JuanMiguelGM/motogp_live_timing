import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "svg", "car"]
  static values = { sessionId: Number }

  connect() {
    this.pendingUpdates = new Map()
    this.flushScheduled = false
  }

  updateBikePosition(data) {
    this.pendingUpdates.set(String(data.rider_number), data)

    if (!this.flushScheduled) {
      this.flushScheduled = true
      requestAnimationFrame(() => this.flushUpdates())
    }
  }

  flushUpdates() {
    this.pendingUpdates.forEach((data, riderNumber) => {
      const bike = this.carTargets.find(
        el => el.dataset.riderNumber === riderNumber
      )
      if (!bike) return
      bike.setAttribute("transform", `translate(${data.x.toFixed(1)}, ${data.y.toFixed(1)})`)
    })

    this.pendingUpdates.clear()
    this.flushScheduled = false
  }
}
