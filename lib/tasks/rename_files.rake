namespace :pdfs do
  desc 'rename filenames'
  task :rename => :environment do |t|
    Pdf.all.each do |pdf|
      if pdf.path
        puts "\t*IGNORE* Reloated Path\t\t#{pdf.full_path}"
      elsif pdf.full_path == pdf.new_full_path
        puts "\t*IGNORE* Already renamed\t\t#{pdf.full_path}"
      elsif pdf.category.nil?
        puts "\t*IGNORE* Category blank\t\t#{pdf.full_path}"
      else
        puts "ID:#{pdf.id}-#{pdf.full_path} \t-> #{pdf.new_full_path}"        
        
        # Safe to rename the file
        
      end

    end
  end
end
