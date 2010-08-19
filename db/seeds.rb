# Build default data
# rake db:seed

# Create default user
password = 'pdfcat'

u = User.new(:login => 'admin',
             :password => password,
             :password_confirmation => password,
             :is_admin => true,
             :firm_id => 1)

u.crypted_password = u.encrypt(password)
u.save

