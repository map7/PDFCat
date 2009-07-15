class CreateDefaultUser < ActiveRecord::Migration
  def self.up

    password = 'pdfcat'

    u = User.new
    u.login = 'admin'
    u.password = password
    u.password_confirmation = password
    u.crypted_password = u.encrypt(password)
    u.is_admin = true
    u.save

  end

  def self.down
    u = User.find_by_login('admin')
    u.destroy unless u.nil?
  end
end
