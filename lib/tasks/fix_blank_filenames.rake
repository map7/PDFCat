namespace :fix do
  desc 'Change all filenames to description only!'
  task :blank_filenames => :environment do |t|
    limit = ENV['LIMIT'] || Pdf.count

    Pdf.find(:all, :conditions => {:missing_flag => false}, :order => "ID DESC",:limit => limit).each do |pdf|
      if File.exists?(pdf.full_path) && pdf.pdfname == ""
        dir = File.dirname(pdf.full_path)
        newfilename = "#{pdf.pdfdate}.pdf".gsub(/ /,"_")
        newpath = "#{dir}/#{newfilename}"

        puts "Fix filename for #{pdf.id} \n\t#{pdf.filename} \n\t#{newfilename}\n"

        if File.exists?(newpath)
          puts "ERROR #{pdf.id}: Filename already exists"
        else
          # Move the file
          FileUtils.mv(pdf.full_path, newpath)

          # Update pdf filename to the full path
          pdf.update_attribute(:pdfname, pdf.description)
          pdf.update_attribute(:filename, newfilename)
          pdf.update_attribute(:path, dir)
        end
      end
    end
    
  end
end
