class ClockworkEventsData < ActiveRecord::Migration
  def self.up
    ClockworkEvent.create(name: 'send_reminders', job: 'SendReminders', frequency_quantity: 1, frequency_period: 'hour', at: '**:10')
    ClockworkEvent.create(name: 'health_update', job: 'HealthUpdate', frequency_quantity: 1, frequency_period: 'day', at: '23:30')
    ClockworkEvent.create(name: 'update_indicators', job: 'UpdateIndicators', frequency_quantity: 1, frequency_period: 'hour', at: '**:00')
    ClockworkEvent.create(name: 'expire_cahces', job: 'ExpireCaches', frequency_quantity: 1, frequency_period: 'hour', at: '**:20')
  end

  def self.down
    ClockworkEvent.delete_all
  end
end
