require File.dirname(__FILE__) + '/../test_helper'

class ClientTest < Test::Unit::TestCase
  fixtures :clients

  # Create
  def test_should_create_client
	  client = Client.new

	  client.name = "Test client"
	  client.email = "map7@iinet.com.au"

	  assert client.save
  end

  # Read
  def test_should_find_client
	  client = clients(:digitech).id

	  assert_nothing_raised { Client.find(client) }
  end

  # Update
  def test_should_update_client
	  client = clients(:digitech)

	  assert client.update_attributes(:email => 'map7@iinet.com.au')
  end

  # Destroy
  def test_should_destroy_client
	  client = clients(:digitech)
	  client.destroy

	  assert_raise(ActiveRecord::RecordNotFound) { Client.find(client.id) }
  end

  # Test validations
  def test_should_not_create_invalid_client
	  client = Client.new

	  assert !client.valid?
	  assert client.errors.invalid?(:name)
	  assert_equal "can't be blank", client.errors.on(:name)
	  assert !client.save
  end

  def test_should_not_create_duplicate_client_name
	  client = Client.new

	  client.name = 'Digitech Corporation'
	  assert !client.valid?
	  assert client.errors.invalid?(:name)
	  assert_equal "has already been taken", client.errors.on(:name)
	  assert !client.save
  end

  def test_should_not_create_false_client_email
	  client = Client.new

	  client.email = 'a'
	  assert !client.valid?
	  assert client.errors.invalid?(:email)
	  assert_equal "is invalid", client.errors.on(:email)
	  assert !client.save
  end

end
