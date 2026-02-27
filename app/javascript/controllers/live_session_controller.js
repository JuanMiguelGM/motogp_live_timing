import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  static values = { sessionId: Number, live: Boolean }

  connect() {
    if (!this.liveValue) return

    this.subscribe()
  }

  disconnect() {
    this.unsubscribe()
  }

  subscribe() {
    this.subscription = consumer.subscriptions.create(
      { channel: "SessionChannel", session_id: this.sessionIdValue },
      {
        connected: () => this.handleConnected(),
        disconnected: () => this.handleDisconnected(),
        received: (data) => this.handleReceived(data)
      }
    )
  }

  unsubscribe() {
    if (this.subscription) {
      this.subscription.unsubscribe()
      this.subscription = null
    }
  }

  handleConnected() {
    const badge = document.querySelector("[data-live-indicator]")
    if (badge) badge.classList.remove("hidden")
  }

  handleDisconnected() {
    const badge = document.querySelector("[data-live-indicator]")
    if (badge) badge.classList.add("hidden")
  }

  handleReceived(data) {
    switch (data.type) {
      case "timing_update":
        this.dispatchTimingUpdate(data.entries)
        break
      case "position_update":
        this.dispatchPositionUpdate(data.positions)
        break
      case "race_direction_update":
        this.dispatchRaceDirectionUpdate(data.messages, data.current_flag)
        break
      case "weather_update":
        this.dispatchWeatherUpdate(data.weather)
        break
    }
  }

  dispatchTimingUpdate(entries) {
    const timingTower = this.application.getControllerForElementAndIdentifier(
      this.element, "timing-tower"
    )
    if (!timingTower) return

    entries.forEach(entry => timingTower.updateRow(entry))
    timingTower.reorderRows()
  }

  dispatchPositionUpdate(positions) {
    const trackMap = this.application.getControllerForElementAndIdentifier(
      this.element, "track-map"
    )
    if (!trackMap) return

    positions.forEach(pos => trackMap.updateBikePosition(pos))
  }

  dispatchRaceDirectionUpdate(messages, currentFlag) {
    // Update flag banner
    const flagController = this.findController(document.querySelector("[data-controller~='flag']"), "flag")
    if (flagController) flagController.updateFlag(currentFlag)

    // Update race direction feed
    const rdController = this.findController(
      this.element.querySelector("[data-controller~='race-direction']"), "race-direction"
    )
    if (rdController && messages?.length) {
      messages.slice().reverse().forEach(msg => rdController.addMessage(msg))
    }
  }

  dispatchWeatherUpdate(weather) {
    const weatherController = this.findController(
      document.querySelector("[data-controller~='weather']"), "weather"
    )
    if (weatherController) weatherController.updateWeather(weather)
  }

  findController(element, identifier) {
    if (!element) return null
    return this.application.getControllerForElementAndIdentifier(element, identifier)
  }
}
