namespace :pdfs do
  desc 'rename filenames'
  task :rename => :environment do |t|
    Pdf.all.each do |pdf|
      if pdf.path
        puts "\t*IGNORE* Relocated Path\t\tID: #{pdf.id}-#{pdf.full_path}"

        # Get the file object

        # Put the date onto the end

        # Rename file

        # Fix up database
        
      elsif pdf.client.nil?
        puts "\t*IGNORE* Client missing\t\tID: #{pdf.id}"
      elsif pdf.category.nil?
        puts "\t*IGNORE* Category missing\t\tID: #{pdf.id}-#{pdf.full_path}"
        
        # Assign to a category

        # Rename file

        # Fix up database
        
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
  end
end
