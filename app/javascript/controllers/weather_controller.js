import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "airTemp", "trackTemp", "humidity", "wind", "rain"]

  updateWeather(data) {
    if (!data) return

    if (this.hasAirTempTarget) this.airTempTarget.textContent = `Air ${data.air_temperature}°C`
    if (this.hasTrackTempTarget) this.trackTempTarget.textContent = `Track ${data.track_temperature}°C`
    if (this.hasHumidityTarget) this.humidityTarget.textContent = `${Math.round(data.humidity)}% RH`
    if (this.hasWindTarget) this.windTarget.textContent = `Wind ${data.wind_speed} m/s`

    if (this.hasRainTarget) {
      if (data.rainfall > 0) {
        this.rainTarget.classList.remove("hidden")
      } else {
        this.rainTarget.classList.add("hidden")
      }
    }
  }
}
