namespace :pdfs do
  desc 'Try and find missing pdfs by md5'
  task :find => :environment do |t|
    Pdf.relink_all
  end
end
