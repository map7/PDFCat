class ChangeMissingFlagDefaultPdf < ActiveRecord::Migration
  def self.up
    change_column_default(:pdfs, :missing_flag, false)
  end

  def self.down
    change_column_default(:pdfs, :missing_flag, nil)
  end
end
