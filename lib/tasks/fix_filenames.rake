namespace :fix do
  desc 'Change all filenames to description only!'
  task :filenames => :environment do |t|

    Pdf.find(:all, :conditions => {:missing_flag => false}, :order => "ID DESC",:limit => 1).each do |pdf|
      if File.exists?(pdf.full_path)
        dir = File.dirname(pdf.full_path)
        newfilename = "#{pdf.description}.pdf".gsub(/ /,"_")
        newpath = "#{dir}/#{newfilename}"

        puts "Fix filename for #{pdf.id} \n\t#{pdf.full_path} \n\t#{newpath}\n"

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
      else
        puts "ERROR #{pdf.id}: Lost file"
      end
    end
    
  end
end
