import { Controller } from "@hotwired/stimulus"

const FORMATS = {
  datetime: { month: "short", day: "numeric", year: "numeric", hour: "2-digit", minute: "2-digit" },
  time: { hour: "2-digit", minute: "2-digit", second: "2-digit" },
  date: { month: "short", day: "numeric", year: "numeric" },
  short_date: { month: "short", day: "numeric" },
  day_time: { weekday: "short", month: "short", day: "numeric", hour: "2-digit", minute: "2-digit" },
  full: { weekday: "long", month: "long", day: "numeric", year: "numeric", hour: "2-digit", minute: "2-digit" }
}

export default class extends Controller {
  connect() {
    this.convertAll()
  }

  convertAll() {
    this.element.querySelectorAll("time.local-time").forEach(el => {
      const iso = el.getAttribute("datetime")
      if (!iso) return

      const date = new Date(iso)
      if (isNaN(date)) return

      const format = el.dataset.localTimeFormat || "datetime"
      const options = FORMATS[format] || FORMATS.datetime
      el.textContent = date.toLocaleString(undefined, options)
    })
  }
}
