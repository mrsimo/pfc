class Time
  # serializes times to the xmlschema format
  def to_json(*a)
    xmlschema.inspect
  end
end

class JSON::Parser
  # parses xmlschema strings into a Time
  def parse_string_with_time_parsing
    s = parse_string_without_time_parsing
    s =~ /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z|(-\d{2}:\d{2})$/ ? Time.parse(s) : s
  end
  alias_method_chain :parse_string, :time_parsing
end