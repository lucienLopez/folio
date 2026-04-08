import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel"]
  static values = { storageKey: { type: String, default: "table-columns" } }

  connect() {
    this.columns = this.loadColumns()
    this.applyColumnVisibility()
    this.renderPanel()
    this.outsideClickHandler = this.closePanel.bind(this)
  }

  disconnect() {
    document.removeEventListener("click", this.outsideClickHandler)
  }

  togglePanel(event) {
    event.stopPropagation()
    const panel = this.panelTarget
    const isHidden = panel.classList.contains("hidden")
    if (isHidden) {
      panel.classList.remove("hidden")
      document.addEventListener("click", this.outsideClickHandler)
    } else {
      panel.classList.add("hidden")
      document.removeEventListener("click", this.outsideClickHandler)
    }
  }

  closePanel() {
    this.panelTarget.classList.add("hidden")
    document.removeEventListener("click", this.outsideClickHandler)
  }

  toggleColumn(event) {
    const id = event.target.dataset.columnId
    const col = this.columns.find(c => c.id === id)
    if (!col) return
    col.visible = event.target.checked
    this.saveColumns()
    this.applyColumnVisibility()
  }

  // ── Private ────────────────────────────────────────────────────────────────

  discoverColumns() {
    return Array.from(this.element.querySelectorAll("th[data-column]")).map(th => ({
      id: th.dataset.column,
      label: th.textContent.trim(),
      visible: th.dataset.columnDefault !== "false",
    }))
  }

  loadColumns() {
    const discovered = this.discoverColumns()
    try {
      const saved = JSON.parse(localStorage.getItem(this.storageKeyValue))
      if (saved) {
        return discovered.map(col => ({ ...col, visible: saved[col.id] ?? col.visible }))
      }
    } catch (_) { /* ignore parse errors */ }
    return discovered
  }

  saveColumns() {
    const prefs = Object.fromEntries(this.columns.map(c => [c.id, c.visible]))
    localStorage.setItem(this.storageKeyValue, JSON.stringify(prefs))
  }

  applyColumnVisibility() {
    this.columns.forEach(({ id, visible }) => {
      this.element.querySelectorAll(`[data-column="${id}"]`).forEach(el => {
        el.classList.toggle("hidden", !visible)
      })
    })
  }

  renderPanel() {
    this.panelTarget.innerHTML = this.columns.map(col => `
      <label class="flex items-center gap-2 px-3 py-1.5 hover:bg-gray-50 rounded-md cursor-pointer text-sm text-gray-700 select-none">
        <input type="checkbox" class="rounded accent-indigo-600" data-column-id="${col.id}"
               data-action="change->column-toggle#toggleColumn" ${col.visible ? "checked" : ""}>
        ${col.label}
      </label>
    `).join("")
  }
}
