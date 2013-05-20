class Milestones < ActiveRecord::Migration
  def self.up
    create_table :milestones do |t|
      t.decimal  :value
      t.date     :date
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_column :indicator_histories, :goal, :decimal
  end

  def self.down
    remove_column :indicator_histories, :goal

    drop_table :milestones
  end
end
