# frozen_string_literal: true

module TimingHelper
  TIRE_COLORS = {
    'SOFT' => 'text-red-400',
    'MEDIUM' => 'text-yellow-400',
    'HARD' => 'text-gray-300',
    'INTERMEDIATE' => 'text-green-400',
    'WET' => 'text-blue-400'
  }.freeze

  TIRE_SHORT = {
    'SOFT' => 'S',
    'MEDIUM' => 'M',
    'HARD' => 'H',
    'INTERMEDIATE' => 'I',
    'WET' => 'W'
  }.freeze

  def format_gap(gap)
    return '' if gap.blank?
    return 'LEADER' if ['0.000', '0'].include?(gap)

    gap.start_with?('+') ? gap : "+#{gap}"
  end

  def format_interval(interval)
    return '' if interval.blank?

    interval
  end

  def sector_color_class(entry, sector_num)
    pb = entry.send(:"sector_#{sector_num}_pb")
    sb = entry.send(:"sector_#{sector_num}_sb")

    if sb
      'text-purple-400 font-bold'
    elsif pb
      'text-green-400'
    else
      'text-gray-300'
    end
  end

  def tire_compound_class(compound)
    TIRE_COLORS[compound&.upcase] || 'text-gray-400'
  end

  def tire_short_name(compound)
    TIRE_SHORT[compound&.upcase] || compound&.first || '-'
  end

  def team_color_style(team)
    return '' if team&.colour.blank?

    "border-left: 3px solid ##{team.colour}"
  end

  def team_color_dot(team)
    return '' if team&.colour.blank?

    tag.span('', class: 'inline-block w-2 h-2 rounded-full mr-1',
                 style: "background-color: ##{team.colour}")
  end

  FLAG_CLASSES = {
    'GREEN' => 'text-green-400',
    'YELLOW' => 'text-yellow-400',
    'DOUBLE YELLOW' => 'text-yellow-400',
    'RED' => 'text-red-500',
    'CHEQUERED' => 'text-white',
    'BLUE' => 'text-blue-400',
    'BLACK AND WHITE' => 'text-gray-300'
  }.freeze

  def flag_message_class(flag)
    FLAG_CLASSES[flag] || 'text-gray-400'
  end
end
