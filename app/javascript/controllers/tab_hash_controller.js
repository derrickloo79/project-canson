import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const hash = window.location.hash.slice(1)
    if (!hash) return
    const radio = document.getElementById(hash)
    if (radio && radio.type === "radio") radio.checked = true
  }
}
