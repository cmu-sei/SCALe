  def numToVerdict(n)
    case n
    when 1
      "Ignored"
    when 2
      "False"
    when 3
      "Suspicious"
    when 4
      "True"
    else
      "Unknown"
    end
  end