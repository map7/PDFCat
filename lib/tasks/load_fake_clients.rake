if Rails.env.development?
  require 'faker'

  namespace :db do

    task :load_fake_clients => :environment do
      firm = Firm.first

      30.times do |index|
        firm.clients.create(
                            name: Faker::Name.name,
                            email: Faker::Internet.email
                           )
      end
    end
  end
end
