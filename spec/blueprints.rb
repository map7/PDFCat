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

Firm.blueprint do
  name { "Digitech" }
  store_dir  {"/home/map7/pdfcat_test_clt"}
  upload_dir {"/home/map7/pdfcat_test_upload"}
end

Category.blueprint do
  firm
  name {"General"}
end

Client.blueprint do
  firm
  name {"Publishing Solutions"}
  email {"aep@publishing-solutions.com.au"}
end

Pdf.blueprint do
  firm
  client
  category
  pdfdate {Date.parse("28-01-2010")}
  pdfname {"Unit Trust Deed"}
  filename {"20100128-unit_trust_deed.pdf"}
end
