def record_valid(result, pdf)
  # Record valid/invalid
  if result =~ /not valid/
    puts "ID: #{pdf.id}\t is INVALID\t#{pdf.filename}"
    pdf.update_attribute(:is_valid, false)
  else
    puts "ID: #{pdf.id}\t is VALID\t#{pdf.filename}"
    pdf.update_attribute(:is_valid, true)
  end
end

def test_if_valid(pdf)
  result = `jhove -m pdf-hul "#{pdf.full_path}" | grep -a "Status:"`
  record_valid(result, pdf)
end

def print_summary
  invalid = Pdf.find(:all, :conditions => {:is_valid => false}).count
  valid = Pdf.find(:all, :conditions => {:is_valid => true}).count

  puts "\n--------------------------------------------------------------------------------"
  puts "\nSummary" \
    "\nInvalid:\t#{invalid}" \
    "\nValid:\t\t#{valid}"
  puts "\n--------------------------------------------------------------------------------"
end

namespace :pdfs do
  desc 'Go through all pdfs and test if they are valid or not'
  task :find_invalid => :environment do |t|

    conditions = {:missing_flag => false}
    conditions[:is_valid] = nil unless ENV['CHECK_ALL']

    Pdf.find(:all, :conditions => conditions).each do |pdf|
      test_if_valid(pdf) if File.exists?(pdf.full_path)
    end

    print_summary
  end
end
