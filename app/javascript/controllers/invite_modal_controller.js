import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "checkbox", "sendLabel", "submit"]

  connect() {
    this.updateCount()
  }

  open(event) {
    event.preventDefault()
    this.modalTarget.showModal()
  }

  close() {
    this.modalTarget.close()
  }

  selectAll() {
    this.checkboxTargets.forEach(cb => { cb.checked = true })
    this.updateCount()
  }

  unselectAll() {
    this.checkboxTargets.forEach(cb => { cb.checked = false })
    this.updateCount()
  }

  updateCount() {
    const n = this.checkboxTargets.filter(cb => cb.checked).length
    this.sendLabelTarget.textContent = n > 0 ? `Send Invite (${n})` : "Send Invite"
    this.submitTarget.disabled = n === 0
  }
}