namespace :pdfs do
  desc 'rename filenames'
  task :rename => :environment do |t|
    @rerun = false
    
    Pdf.all.each do |pdf|
      if pdf.client.nil?
        puts "\t*IGNORE* Client missing\t\tID: #{pdf.id}"
      elsif pdf.category.nil?
        puts "\t*IGNORE* Category missing\tID: #{pdf.id}-#{pdf.full_path}"

      elsif File.exists?(pdf.path) # Check relocated path exists

        # Get the filename
        f=File.basename pdf.full_path

        # Get path
        pdf.path

        # Get date from start of relocated file
        date=f.match(/^\d{8}/).to_s

        if date == ""
          puts "\t*IGNORE* Already renamed\tID: #{pdf.id}-#{pdf.full_path}"
          
        else
          puts "\t*IGNORE* Relocated Path\t\tID: #{pdf.id}-#{pdf.full_path}"

          # Get the filename
          filename=f.match(/[^^\d{8}-].*[^$.pdf]/).to_s
          
          # Form new filename
          newfilename = "#{filename}-#{date}.pdf"

          newpath = "#{pdf.path}/#{newfilename}"

          if File.exists?(pdf.full_path)
            puts "\t\t\t\t\t       #{newpath}"

            # Rename file
            FileUtils.mv(pdf.full_path, newpath)
            
            # Fix up database
            pdf.update_attribute(:filename, newfilename)
          end
        end
        

        
      elsif pdf.category && pdf.client && pdf.full_path == pdf.new_full_path
        puts "\t*IGNORE* Already renamed\tID: #{pdf.id}-#{pdf.full_path}"
      elsif File.exists?(pdf.full_path)
        puts "ID:#{pdf.id}-#{pdf.full_path} \t-> #{pdf.new_full_path}"       
        
        # Safe to rename the file
        FileUtils.mv(pdf.full_path, pdf.new_full_path)

        # Save the new filename
        pdf.update_attribute(:filename, pdf.get_new_filename2)
      else
        puts "\t*IGNORE* File missing\t\tID: #{pdf.id}-#{pdf.full_path}"
      end
    end

    puts "Please rerun this rake task as some files have been fixed up" if @rerun
  end # task
end # namespace
