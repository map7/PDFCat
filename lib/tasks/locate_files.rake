namespace :pdfs do
  desc 'Use locate to try and fuzzy match some of the file'
  task :locate => :environment do |t|
    Firm.find(:all).each do|firm|

      puts "FIRM #{firm.name}"
      puts "#{firm.store_dir}"


      # For each pdf
      firm.pdfs.each do|pdf|

        if pdf.missing_flag

          # Reset variables
          locates = {}
          selected = nil

          # Display a heading
          puts pdf.pdfname

          # Locate files
          result = `locate -ir  \"^#{firm.store_dir}.*#{pdf.pdfname}.*\" --limit 30`

          # Store the results
          results = result.split("\n")
          results.each_with_index do |file, i|
            puts "#{i + 1} - #{file}"
            locates[i + 1] = file
          end

          # Allow user to select the appropriate file
          puts "\nPlease select a file or hit enter for none:"
          a = STDIN.gets.chomp.to_i

          if a > 0 and a < locates.count + 1
            selected = locates[a]
            puts "#{selected} - selected"

            # Set the path for the pdf
            pdf.path = File.dirname(selected)
            pdf.filename = File.basename(selected)
            pdf.missing_flag = false
            pdf.save
          else
            puts "Nothing selected"
          end
        end # if missing
      end   # pdfs
    end     # firms
  end       # task
end         # namespace
