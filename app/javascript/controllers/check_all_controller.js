import { Controller } from "@hotwired/stimulus"

// Selects or deselects all enabled checkboxes within the controller's element.
//
// Usage:
//   <div data-controller="check-all">
//     <button type="button" data-action="check-all#selectAll">Select all</button>
//     <button type="button" data-action="check-all#deselectAll">Unselect all</button>
//     <input type="checkbox" ...>
//   </div>

export default class extends Controller {
  selectAll() {
    this.#checkboxes().forEach(cb => { cb.checked = true })
  }

  deselectAll() {
    this.#checkboxes().forEach(cb => { cb.checked = false })
  }

  #checkboxes() {
    return Array.from(this.element.querySelectorAll("input[type=checkbox]:not(:disabled)"))
  }
}
