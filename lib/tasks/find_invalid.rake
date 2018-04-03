namespace :pdfs do
  desc 'Go through all pdfs and test if they are valid or not'
  task :find_invalid => :environment do |t|

    Pdf.find(:all, :conditions => {:missing_flag => false, :is_valid => nil}).each do |pdf|
      if File.exists?(pdf.full_path)

        # Test if valid
        puts "testing: #{pdf.full_path}"
        result = `jhove -m pdf-hul "#{pdf.full_path}" | grep -a "Status:"`

        # Record valid/invalid
        if result =~ /Well-Formed and valid/
          puts "#{pdf.filename} is valid"
          pdf.update_attribute(:is_valid, true)
        else
          puts "#{pdf.filename} is invalid"
          pdf.update_attribute(:is_valid, false)
        end

      end

    end

    # Print summary
    invalid = Pdf.find(:all, :conditions => {:is_valid => false}).count
    valid = Pdf.find(:all, :conditions => {:is_valid => true}).count

    puts "\n--------------------------------------------------------------------------------"
    puts "\nSummary" \
      "\nInvalid:\t#{invalid}" \
      "\nValid:\t\t#{valid}"
    puts "\n--------------------------------------------------------------------------------"
    
  end
end
