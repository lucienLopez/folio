# frozen_string_literal: true

module SecuritiesHelper
  def security_kind_badge(kind)
    return content_tag(:span, '—', class: 'text-gray-400') if kind.blank?

    content_tag(:span, kind.humanize, class: "badge #{kind}")
  end
end
