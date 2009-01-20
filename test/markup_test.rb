require File.dirname(__FILE__) + '/test_helper'

class CalendarForTest < Test::Unit::TestCase
  
  def test_basic_tag
    assert_equal "<p></p>", Markup.new(:p)
  end

end