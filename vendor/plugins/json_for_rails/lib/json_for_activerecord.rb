ActiveRecord::Base.class_eval do
  # PDI adding similar #to_xml options like :include, :exclude, etc
  def to_json
    attributes.to_json
  end
end

ActiveRecord::Errors.class_eval do
  def to_json
    full_messages.to_json
  end
end