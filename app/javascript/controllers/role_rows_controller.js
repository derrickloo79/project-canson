import { Controller } from "@hotwired/stimulus"

// Manages dynamic role rows in the Step 2 wizard:
// - Add new rows by cloning the hidden <template>
// - Remove rows (soft-delete for persisted records, hard-remove for new ones)
// - Live-update the summary panel as the user types
//
// Usage:
//   data-controller="role-rows"
//   data-role-rows-index-value="<current row count>"

export default class extends Controller {
  static targets = ["rowContainer", "template", "summary"]
  static values  = { index: Number }

  connect() {
    this.updateSummary()
  }

  addRow(event) {
    event.preventDefault()

    const templateContent = this.templateTarget.innerHTML
      .replace(/NEW_RECORD/g, this.indexValue)

    this.rowContainerTarget.insertAdjacentHTML("beforeend", templateContent)
    this.indexValue++
    this.updateSummary()
    this.hideEmptyMessage()
  }

  removeRow(event) {
    event.preventDefault()

    const row = event.target.closest("[data-role-row]")
    const destroyField = row.querySelector("[data-destroy-field]")

    if (destroyField) {
      // Persisted record: mark for destruction and hide visually
      destroyField.value = "1"
      row.classList.add("hidden")
    } else {
      // Unsaved new row: remove from DOM entirely
      row.remove()
    }

    this.updateSummary()
  }

  // Called via data-action="input->role-rows#rowChanged" on vacancies/time fields
  rowChanged() {
    this.updateSummary()
  }

  updateSummary() {
    if (!this.hasSummaryTarget) return

    const visibleRows = Array.from(
      this.rowContainerTarget.querySelectorAll("[data-role-row]")
    ).filter(row => !row.classList.contains("hidden"))

    let totalVacancies = 0
    let earliestStart  = null
    let latestEnd      = null

    visibleRows.forEach(row => {
      const vacancyEl  = row.querySelector("[data-vacancies]")
      const startEl    = row.querySelector("[data-shift-start]")
      const endEl      = row.querySelector("[data-shift-end]")

      const vacancies  = parseInt(vacancyEl?.value) || 0
      const shiftStart = startEl?.value || null
      const shiftEnd   = endEl?.value || null

      totalVacancies += vacancies

      if (shiftStart && (!earliestStart || shiftStart < earliestStart)) {
        earliestStart = shiftStart
      }
      if (shiftEnd && (!latestEnd || shiftEnd > latestEnd)) {
        latestEnd = shiftEnd
      }
    })

    const summary = this.summaryTarget
    this.setText(summary, "[data-summary-roles]",     visibleRows.length)
    this.setText(summary, "[data-summary-vacancies]", totalVacancies)
    this.setText(summary, "[data-summary-start]",     this.formatTime(earliestStart))
    this.setText(summary, "[data-summary-end]",       this.formatTime(latestEnd))
  }

  // Private helpers

  setText(parent, selector, value) {
    const el = parent.querySelector(selector)
    if (el) el.textContent = value
  }

  formatTime(value) {
    if (!value) return "—"
    // value is "HH:MM" from <input type="time">
    return value
  }

  hideEmptyMessage() {
    const msg = this.element.querySelector("[data-empty-message]")
    if (msg) msg.remove()
  }
}
