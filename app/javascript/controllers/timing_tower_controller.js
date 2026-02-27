import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "tbody"]
  static values = { sessionId: Number }

  connect() {
    this.previousPositions = {}
    this.fastestLap = null
    this.reorderPending = false
  }

  updateRow(data) {
    const row = this.tbodyTarget.querySelector(`tr[data-rider-number="${data.rider_number}"]`)
    if (!row) return

    // Track position changes for animations
    const prevPos = this.previousPositions[data.rider_number]
    this.previousPositions[data.rider_number] = data.position
    this.animatePositionChange(row, prevPos, data.position)

    this.setCellText(row, 0, data.position)
    this.setCellText(row, 2, data.interval || "")
    this.setCellText(row, 3, this.formatGap(data.gap_to_leader))
    this.setCellText(row, 4, data.last_lap_time || "")
    this.setCellText(row, 5, data.best_lap_time || "")
    this.setCellText(row, 6, data.sector_1_time || "")
    this.setCellText(row, 7, data.sector_2_time || "")
    this.setCellText(row, 8, data.sector_3_time || "")
    // Columns 9 (tire) and 10 (pit) handled by inner spans
    this.setCellText(row, 11, data.top_speed || "-")
    this.setCellText(row, 12, data.total_laps || "-")
    this.setCellText(row, 13, data.status || "")

    // Check for fastest lap
    this.checkFastestLap(row, data)

    // Schedule a debounced reorder
    if (!this.reorderPending) {
      this.reorderPending = true
      requestAnimationFrame(() => {
        this.reorderRows()
        this.reorderPending = false
      })
    }
  }

  reorderRows() {
    const rows = Array.from(this.tbodyTarget.querySelectorAll("tr"))
    rows.sort((a, b) => {
      const posA = parseInt(a.cells[0]?.textContent) || 99
      const posB = parseInt(b.cells[0]?.textContent) || 99
      return posA - posB
    })

    rows.forEach(row => this.tbodyTarget.appendChild(row))
  }

  setCellText(row, index, text) {
    const cell = row.cells[index]
    if (cell) {
      const span = cell.querySelector("span") || cell
      span.textContent = text
    }
  }

  formatGap(gap) {
    if (!gap || gap === "0.000" || gap === "0") return "LEADER"
    return gap.startsWith("+") ? gap : `+${gap}`
  }

  animatePositionChange(row, prevPos, newPos) {
    if (prevPos === undefined || prevPos === newPos) return

    // Remove existing indicators
    row.querySelectorAll(".pos-change").forEach(el => el.remove())

    const cell = row.cells[0]
    if (!cell) return

    const indicator = document.createElement("span")
    indicator.className = "pos-change text-[10px] ml-1"

    if (newPos < prevPos) {
      indicator.textContent = `▲${prevPos - newPos}`
      indicator.classList.add("text-green-400")
    } else {
      indicator.textContent = `▼${newPos - prevPos}`
      indicator.classList.add("text-red-400")
    }

    cell.appendChild(indicator)

    // Remove indicator after 5 seconds
    setTimeout(() => indicator.remove(), 5000)
  }

  checkFastestLap(row, data) {
    if (!data.best_lap_time) return

    const lapTime = this.parseLapTime(data.best_lap_time)
    if (lapTime === null) return

    if (this.fastestLap === null || lapTime < this.fastestLap.time) {
      // Remove previous purple highlight
      if (this.fastestLap?.row) {
        this.fastestLap.row.classList.remove("fastest-lap-row")
      }

      this.fastestLap = { time: lapTime, row: row, rider: data.rider_acronym }
      row.classList.add("fastest-lap-row")

      this.showFastestLapToast(data)
    }
  }

  parseLapTime(timeStr) {
    if (!timeStr) return null

    const parts = timeStr.split(":")
    if (parts.length === 2) {
      return parseFloat(parts[0]) * 60 + parseFloat(parts[1])
    }
    return parseFloat(timeStr)
  }

  showFastestLapToast(data) {
    // Remove existing toast
    document.querySelectorAll(".fastest-lap-toast").forEach(el => el.remove())

    const toast = document.createElement("div")
    toast.className = "fastest-lap-toast fixed top-16 right-4 bg-purple-400 text-white px-4 py-2 rounded-lg text-sm font-bold z-50 transition-opacity duration-500"
    toast.textContent = `FASTEST LAP: ${data.rider_acronym} - ${data.best_lap_time}`

    document.body.appendChild(toast)

    setTimeout(() => {
      toast.style.opacity = "0"
      setTimeout(() => toast.remove(), 500)
    }, 4000)
  }
}
