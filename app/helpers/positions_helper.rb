# frozen_string_literal: true

module PositionsHelper
  def position_row_style(position)
    return unless position.gain_pct

    gain = position.gain_pct.to_f
    intensity = [(gain.abs / 30.0), 1.0].min * 0.4
    return if intensity < 0.01

    color = gain >= 0 ? "34 197 94" : "239 68 68"
    "--row-color: #{color}; --row-alpha: #{intensity.round(3)};"
  end
end
