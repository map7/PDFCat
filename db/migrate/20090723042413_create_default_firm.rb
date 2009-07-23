class CreateDefaultFirm < ActiveRecord::Migration
  def self.up
    Firm.create :name => "default", :store_dir => "/tmp", :upload_dir => "/tmp"
  end

  def self.down
  end
end
