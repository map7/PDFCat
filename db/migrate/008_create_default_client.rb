class CreateDefaultClient < ActiveRecord::Migration
  def self.up
    Client.create :name => 'default', :firm_id => 1
  end

  def self.down
  end
end
