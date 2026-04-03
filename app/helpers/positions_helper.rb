# frozen_string_literal: true

module PositionsHelper
  def sleeve_weight_color(position)
    return 'text-gray-700' unless position.target_weight

    diff = position.sleeve_weight - position.target_weight
    if diff.abs <= 2
      'text-gray-700'
    elsif diff > 2
      'text-red-500 font-medium'
    else
      'text-blue-500 font-medium'
    end
  end

  def sleeve_weight_bar_color(position)
    return 'bg-indigo-500' unless position.target_weight

    diff = position.sleeve_weight - position.target_weight
    if diff.abs <= 2
      'bg-indigo-500'
    elsif diff > 2
      'bg-red-400'
    else
      'bg-blue-400'
    end
  end

  def position_row_style(position)
    return unless position.gain_pct

    gain = position.gain_pct.to_f
    intensity = [(gain.abs / 30.0), 1.0].min * 0.4
    return if intensity < 0.01

    color = gain >= 0 ? "34 197 94" : "239 68 68"
    "--row-color: #{color}; --row-alpha: #{intensity.round(3)};"
  end
end
