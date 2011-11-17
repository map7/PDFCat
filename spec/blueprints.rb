require 'machinist/active_record'
require 'sham'

User.blueprint do
  login {'map7'}
  name  {'Michael Pope'}
  email {'michael@dtcorp.com.au'}
end

Category.blueprint do
  name {"General"}
end
