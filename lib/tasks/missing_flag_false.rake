namespace :pdfs do
  desc 'change nil to false'
  task :fix_missing_flags => :environment do |t|
    Pdf.find(:all, :conditions => "missing_flag IS NULL").each do |pdf|
      puts "Missing flag nil id: #{pdf.id}-#{pdf.full_path}"
      pdf.update_attribute(:missing_flag, false)
    end
  end
end
