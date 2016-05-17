require 'test_helper'

class IndicatorHistoryTest < ActiveSupport::TestCase
  
  def new_indicator
    ind = Indicator.new
  end
  
  ['1.day.ago', '1.year.ago'].each do |last_update_str|
    {weekly: 1.week, monthly: 1.month, quarterly: 3.month}.each do |freq, inc|
      test "Compute next update last_update=#{last_update_str} and frequency=#{freq}" do
        last_update = eval(last_update_str)
        expected = last_update + inc
        ind = new_indicator
        ind.stubs(:last_update).returns(last_update)
        ind.stubs(:frequency).returns(freq)
        assert_equal expected, ind.compute_next_update
      end
    end
  end
  
  test "Scope latest today" do
    ind = indicators(:one)
    expected_ih = indicator_histories(:three)
    ih = IndicatorHistory.latest(ind.id)
    assert_equal expected_ih, ih
  end
  
  test "Scope latest with exact ih date" do
    ind = indicators(:one)
    expected_ih = indicator_histories(:two)
    ih = IndicatorHistory.latest(ind.id, expected_ih.day)
    assert_equal expected_ih, ih
  end
  
  test "Scope latest with non-exact ih date" do
    ind = indicators(:one)
    expected_ih = indicator_histories(:two)
    ih = IndicatorHistory.latest(ind.id, expected_ih.day + 3.days)
    assert_equal expected_ih, ih
  end
end
