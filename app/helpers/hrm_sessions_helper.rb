module HrmSessionsHelper
  def zone_color(zone, type: :solid)
    case zone
    when 1
      type == :solid ? "rgb(34 197 94 / 0.8)" : "from-green-500/80 to-green-600/80"
    when 2
      type == :solid ? "rgb(234 179 8 / 0.8)" : "from-yellow-500/80 to-yellow-600/80"
    when 3
      type == :solid ? "rgb(249 115 22 / 0.8)" : "from-orange-500/80 to-orange-600/80"
    when 4
      type == :solid ? "rgb(239 68 68 / 0.8)" : "from-red-500/80 to-red-600/80"
    else
      type == :solid ? "rgb(168 85 247 / 0.8)" : "from-purple-500/80 to-purple-600/80"
    end
  end

  def zone_range(zone)
    case zone
    when 1 then "0-120"
    when 2 then "121-140"
    when 3 then "141-160"
    when 4 then "161-180"
    else "180+"
    end
  end
end
