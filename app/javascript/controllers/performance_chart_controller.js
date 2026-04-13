import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["perfChart", "valueChart", "perfBtn", "valueBtn"]

  connect() {
    const stored = localStorage.getItem("performanceChartMode")
    if (stored === "value") this._activateValue()
    else this._activatePerf()
  }

  showPerf() {
    localStorage.setItem("performanceChartMode", "perf")
    this._activatePerf()
  }

  showValue() {
    localStorage.setItem("performanceChartMode", "value")
    this._activateValue()
  }

  _activatePerf() {
    this.perfChartTarget.classList.remove("hidden")
    this.valueChartTarget.classList.add("hidden")
    this.perfBtnTarget.classList.add("bg-white", "text-gray-900", "shadow-sm")
    this.perfBtnTarget.classList.remove("text-gray-500", "hover:text-gray-700")
    this.valueBtnTarget.classList.remove("bg-white", "text-gray-900", "shadow-sm")
    this.valueBtnTarget.classList.add("text-gray-500", "hover:text-gray-700")
  }

  _activateValue() {
    this.valueChartTarget.classList.remove("hidden")
    this.perfChartTarget.classList.add("hidden")
    this.valueBtnTarget.classList.add("bg-white", "text-gray-900", "shadow-sm")
    this.valueBtnTarget.classList.remove("text-gray-500", "hover:text-gray-700")
    this.perfBtnTarget.classList.remove("bg-white", "text-gray-900", "shadow-sm")
    this.perfBtnTarget.classList.add("text-gray-500", "hover:text-gray-700")
  }
}
