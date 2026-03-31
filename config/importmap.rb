# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin 'application'
pin '@hotwired/turbo-rails', to: 'turbo.min.js'
pin '@hotwired/stimulus', to: 'stimulus.min.js'
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js'
pin_all_from 'app/javascript/controllers', under: 'controllers'
pin "tablesort" # @5.7.0
pin "chart.js/auto", to: "https://esm.sh/chart.js@4.5.1/auto?bundle"
pin "chartkick", to: "https://esm.sh/chartkick@5.0.1"
