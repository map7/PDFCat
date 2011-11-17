require 'machinist/active_record'
require 'sham'

User.blueprint do
  login {'map7'}
  name  {'Michael Pope'}
  email {'michael@dtcorp.com.au'}
  salt  { '356a192b7913b04c54574d18c28d46e6395428ab' } # SHA1('0')
  crypted_password { '7f31da8d30980bf79ffa1599861448f6d4c8733d' } # 'monkey'
  firm_id { 1 }
end

Category.blueprint do
  name {"General"}
end
