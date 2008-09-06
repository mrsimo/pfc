require File.dirname(__FILE__) + '/../test_helper'

class ConfigurationTest < Test::Unit::TestCase

 fixtures :configurations

 # The assumption here is that the  record was created already.
 # Once there is a record, it should not allow the creation of an existing one.
  def test_should_not_create
   c = Configuration.create({})
   assert !c.save
  end
  
  # Should not be able to remove the last configuration in the system.
  def test_should_not_delete
   c = Configuration.find :first
   assert !c.destroy
  end
  
  def test_load_method_should_only_find_one
    assert_kind_of(Configuration, Configuration.load)
  end
  
  def test_should_create_new_record_on_load_if_none_found
    Configuration.delete_all
    assert_not_nil Configuration.load
  end
  
  
  
end
