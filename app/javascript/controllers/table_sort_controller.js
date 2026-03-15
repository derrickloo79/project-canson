import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["header"]

  sort(event) {
    const th    = event.currentTarget
    const index = this.headerTargets.indexOf(th)
    const tbody = this.element.querySelector("tbody")
    const rows  = Array.from(tbody.querySelectorAll("tr"))
    const asc   = th.dataset.sortDir !== "asc"

    // Reset all headers
    this.headerTargets.forEach(h => {
      h.dataset.sortDir = ""
      h.querySelector("[data-sort-icon]")?.remove()
    })

    // Mark active header
    th.dataset.sortDir = asc ? "asc" : "desc"
    const icon = document.createElement("span")
    icon.dataset.sortIcon = ""
    icon.textContent = asc ? " ↑" : " ↓"
    icon.className = "text-base-content/40 text-xs"
    th.appendChild(icon)

    // Sort rows by cell text or explicit data-sort-value
    rows.sort((a, b) => {
      const aVal = a.cells[index]?.dataset.sortValue ?? a.cells[index]?.textContent.trim() ?? ""
      const bVal = b.cells[index]?.dataset.sortValue ?? b.cells[index]?.textContent.trim() ?? ""
      return asc
        ? aVal.localeCompare(bVal, undefined, { numeric: true, sensitivity: "base" })
        : bVal.localeCompare(aVal, undefined, { numeric: true, sensitivity: "base" })
    })

    rows.forEach(row => tbody.appendChild(row))
  }
}
