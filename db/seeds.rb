# Build default data
# rake db:seed

# Create default user
password = 'pdfcat'

u = User.new(:login => 'admin',
             :password => password,
             :password_confirmation => password)

u.is_admin = true
u.firm_id = 1
u.crypted_password = u.encrypt(password)
u.save

# Create default client, category & firm
Client.create :name => 'default', :firm_id => 1
Category.create :name => 'default', :firm_id => 1
Firm.create :name => "default", :store_dir => "/tmp", :upload_dir => "/tmp"

