require 'rubygems'
require 'fjson'

rails_path = File.join(File.dirname(__FILE__), "../../../../config/environment.rb")
if false && File.exist?(rails_path)
  require rails_path
  require 'test_help'
else
  require 'test/unit'
  require 'active_support'
  require 'action_controller'
  require 'active_record'
  require File.join(File.dirname(__FILE__), '../lib/json_for_activesupport')
  require File.join(File.dirname(__FILE__), '../lib/json_for_actionpack')
  require File.join(File.dirname(__FILE__), '../lib/json_for_activerecord')
end

# yagni real database
ActiveRecord::Base.class_eval do
  def self.columns() @columns ||= []; end
  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end
end

class Post < ActiveRecord::Base
  column :title, :string
  column :comments_count, :integer
  column :published_at, :datetime
end

class JsonRailsTest < Test::Unit::TestCase
  def test_should_convert_time_to_xmlschema
    t = Time.now
    assert_equal t.xmlschema.inspect, t.to_json
    assert_equal t.utc.xmlschema.inspect, t.utc.to_json
  end
  
  def test_should_parse_xmlschema_time_to_time
    t = Time.now.utc
    assert_equal t.to_i, JSON.parse(t.xmlschema.inspect).to_i
  end

  def test_should_parse_incoming_json
    t = Time.now.utc.midnight
    json = %({"a":1,"b":"2","c":#{t.xmlschema.inspect}})
    assert_equal({'a' => 1, 'b' => '2', 'c' => t}, ActionController::Base.param_parsers[Mime::JSON].call(json))
  end
  
  def test_should_convert_active_record_model_to_json
    p = Post.new(:title => 'check your head', :comments_count => 5, :published_at => Time.now.utc)
    json = p.to_json
    assert_match /"title":"check your head"/, json
    assert_match /"comments_count":5/, json
    assert_match /"published_at":#{p.published_at.xmlschema.inspect}/, json
  end
  
  def test_should_serialize_active_record_errors
    p = Post.new
    p.errors.add :title, "is empty"
    p.errors.add :comments_count, "is empty"
    assert_equal %(["Title is empty","Comments count is empty"]), p.errors.to_json
  end
end