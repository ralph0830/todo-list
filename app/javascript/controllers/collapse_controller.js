import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="collapse"
export default class extends Controller {
  static targets = ["content", "icon", "text"]
  static values = { collapsed: Boolean }

  connect() {
    console.log("Collapse controller connected, collapsed:", this.collapsedValue)
    // 기본적으로 접혀있는 상태로 시작
    this.updateContent()
    this.updateButton()
  }

  toggle() {
    console.log("Toggle clicked, current collapsed:", this.collapsedValue)
    this.collapsedValue = !this.collapsedValue
    console.log("New collapsed value:", this.collapsedValue)
    this.updateContent()
    this.updateButton()
  }

  updateContent() {
    if (this.collapsedValue) {
      // 접기
      this.contentTarget.style.display = "none"
      console.log("Content hidden")
    } else {
      // 펴기
      this.contentTarget.style.display = "block"
      console.log("Content shown")
    }
  }

  updateButton() {
    if (this.hasIconTarget && this.hasTextTarget) {
      if (this.collapsedValue) {
        this.iconTarget.textContent = "▶️"
        this.textTarget.textContent = "펴기"
      } else {
        this.iconTarget.textContent = "▼"
        this.textTarget.textContent = "접기"
      }
      console.log("Button updated, collapsed:", this.collapsedValue)
    }
  }

  // 값이 변경될 때 자동으로 호출되는 콜백
  collapsedValueChanged() {
    console.log("Collapsed value changed to:", this.collapsedValue)
    this.updateContent()
    this.updateButton()
  }
}