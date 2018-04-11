namespace :fix do
  desc 'Change all filenames to description only!'
  task :bak_files => :environment do |t|
    limit = ENV['LIMIT'] || Pdf.count

    Pdf.find(:all, :conditions => {:missing_flag => true}, :order => "ID DESC",:limit => limit).each do |pdf|
      print "."
      
      if File.exists?("#{pdf.full_path}.bak") && !File.exists?(pdf.full_path)
        puts "Fix filename for #{pdf.id} \n\t#{pdf.filename}"
        puts "\tbak file exists"
        puts "\trenaming bak file to original..."
        FileUtils.mv("#{pdf.full_path}.bak", pdf.full_path)
        puts "\tMark pdf as not missing"
      end

      pdf.update_attribute(:missing_flag, false) if File.exists?(pdf.full_path)
    end
    
  end
end
