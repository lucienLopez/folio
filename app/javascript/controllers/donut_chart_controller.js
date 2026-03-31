import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    document.addEventListener("turbo:load", this.#addPercentages)
    // Handle initial page load (module runs after inline scripts, so charts may already be ready)
    this.#addPercentages()
  }

  disconnect() {
    document.removeEventListener("turbo:load", this.#addPercentages)
  }

  #addPercentages = () => {
    const chartEl = [...this.element.querySelectorAll("[id]")]
      .find(el => window.Chartkick?.charts[el.id])
    if (!chartEl) return

    const chart = Chartkick.charts[chartEl.id].getChartObject()
    if (!chart) return

    chart.options.plugins.tooltip.callbacks.label = (context) => {
      const total = context.dataset.data.reduce((a, b) => a + b, 0)
      const value = context.parsed
      const pct = total > 0 ? ((value / total) * 100).toFixed(1) : "0.0"
      const formatted = value.toLocaleString("fr-FR", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
      return ` ${formatted} € (${pct}%)`
    }

    chart.update("none")
  }
}
