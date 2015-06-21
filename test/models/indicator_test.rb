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
  
  test "Update from latest history with null value" do
    ih = indicator_histories(:three)
    ind = indicators(:one)
    ind.update_from_latest_history!
    assert_equal ih.value.to_s, ind.value.to_s
    assert_equal ih.goal.to_s, ind.goal.to_s
    assert_equal ih.day, ind.last_update
  end
  
  test "Update from latest history don't update" do
    ih = indicator_histories(:three)
    ind = indicators(:three)
    exp_val = ind.value
    exp_last = ind.last_update
    exp_goal = ind.goal
    ind.update_from_latest_history!
    assert_equal exp_val.to_s, ind.value.to_s
    assert_equal exp_goal.to_s, ind.goal.to_s
    assert_equal exp_last, ind.last_update
  end
  
  test "Update from latest history update new value" do
    ih = indicator_histories(:nine)
    ind = indicators(:four)
    ind.update_from_latest_history!
    assert_equal ih.value.to_s, ind.value.to_s
    assert_equal ih.goal.to_s, ind.goal.to_s
    assert_equal ih.day, ind.last_update
  end
  
end
