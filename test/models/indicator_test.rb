require 'test_helper'

class IndicatorTest < ActiveSupport::TestCase
  
  def new_indicator
    ind = Indicator.new
  end
  
  ['1.day.ago', '1.year.ago'].each do |last_update_str|
    {weekly: 1.week, monthly: 1.month, quarterly: 3.month}.each do |freq, inc|
      test "Compute next update last_update=#{last_update_str} and frequency=#{freq}" do
        last_update = eval(last_update_str)
        expected = last_update + inc
        ind = new_indicator
        ind.expects(:last_update).returns(last_update)
        ind.expects(:frequency).returns(freq)
        assert_equal expected, ind.compute_next_update
      end
    end
  end
  
  
  
end
