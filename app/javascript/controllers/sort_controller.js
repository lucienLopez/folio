import { Controller } from "@hotwired/stimulus"
import Tablesort from "tablesort"

Tablesort.extend("number", (item) => item.match(/^[-+]?\d*[,.]?\d+$/),
  (a, b) => parseFloat(a.replace(",", ".")) - parseFloat(b.replace(",", "."))
)

export default class extends Controller {
  connect() {
    this.tablesort = new Tablesort(this.element)
  }

  disconnect() {
    this.tablesort.destroy()
  }
}
