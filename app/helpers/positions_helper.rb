# frozen_string_literal: true

module PositionsHelper
  def position_row_class(position)
    return unless position.gain_pct

    case position.gain_pct
    when (30..)     then 'row-gain-strong'
    when (5...30)   then 'row-gain-mild'
    when (-5...5)   then nil
    when (-20...-5) then 'row-loss-mild'
    else                 'row-loss-strong'
    end
  end
end
