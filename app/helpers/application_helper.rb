# frozen_string_literal: true

module ApplicationHelper
  def local_time(time, format: :datetime, **html_options)
    return '' if time.nil?

    time = time.to_time.utc if time.respond_to?(:to_time)
    css = "local-time #{html_options.delete(:class)}".strip
    tag.time(time.strftime(format_string(format)),
             datetime: time.iso8601,
             data: { local_time_format: format.to_s },
             class: css,
             **html_options)
  end

  private

  def format_string(format)
    {
      datetime: '%Y-%m-%d %H:%M UTC',
      time: '%H:%M:%S UTC',
      date: '%b %d, %Y',
      short_date: '%b %d',
      day_time: '%a %b %d, %H:%M UTC',
      full: '%A, %B %d %Y at %H:%M UTC'
    }.fetch(format, '%Y-%m-%d %H:%M UTC')
  end
end
