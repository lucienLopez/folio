// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import Chartkick from "chartkick"
import { Chart } from "chart.js/auto"

Chartkick.addAdapter(Chart)
window.Chartkick = Chartkick
window.dispatchEvent(new Event("chartkick:load"))

document.addEventListener("turbo:load", () => Chartkick.reflow())
