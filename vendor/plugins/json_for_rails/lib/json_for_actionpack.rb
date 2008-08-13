ActionController::Base.param_parsers[Mime::JSON] = Proc.new do |raw_post_data|
  raw_post_data.blank? ? {} : JSON.parse(raw_post_data)
end

module ActionController
  class AbstractRequest
    def content_type_with_json
      @content_type ||= (@env["HTTP_X_REQUEST"].to_s =~ /JSON/i) ? Mime::JSON : content_type_without_json
    end
    
    alias_method_chain :content_type, :json
  end
end