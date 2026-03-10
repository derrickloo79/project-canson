import { Controller } from "@hotwired/stimulus"

// Shows/hides a target element based on a checkbox's checked state.
//
// Usage:
//   <div data-controller="checkbox-toggle">
//     <input type="checkbox" data-action="change->checkbox-toggle#toggle"
//            data-checkbox-toggle-target="checkbox">
//     <div data-checkbox-toggle-target="content" class="hidden">...</div>
//   </div>

export default class extends Controller {
  static targets = ["checkbox", "content", "label"]

  connect() {
    this.toggle()
  }

  toggle() {
    const show = this.checkboxTarget.checked
    this.contentTargets.forEach(el => el.classList.toggle("hidden", !show))
    if (this.hasLabelTarget) {
      this.labelTargets.forEach(el => {
        const text = show ? el.dataset.checkboxToggleCheckedText : el.dataset.checkboxToggleUncheckedText
        if (text) el.textContent = text
      })
    }
  }
}
