require File.dirname(__FILE__) + '/../test_helper'

class CategoryTest < ActiveSupport::TestCase

  def setup
    @firm = firms(:one)
  end

  # Create
  def test_should_create_category
    category = Category.new

    category.name = "Test Category"
    category.description = "This is a unit test"

    assert category.save
  end

  # Read
  def test_should_find_category
    category_id = categories(:bas).id

    assert_nothing_raised { Category.find(category_id) }
  end

  # Update
  def test_should_update_category
    category = categories(:bas)

    assert category.update_attributes(:description => 'New description')
  end

  # Destroy
  def test_should_destroy_category
    category = categories(:bas)
    category.destroy

    assert_raise(ActiveRecord::RecordNotFound) { Category.find(category.id) }
  end

  # Test validations
  def test_should_not_create_invalid_category
    category = Category.new

    assert !category.valid?
    assert category.errors.invalid?(:name)
    assert_equal ["can't be blank","is invalid"], category.errors.on(:name)
    assert !category.save
  end

  def test_should_not_create_duplicate_category_name
    category = Category.new

    category.name = 'tax'
    assert !category.valid?
    assert category.errors.invalid?(:name)
    assert_equal "has already been taken", category.errors.on(:name)
    assert !category.save
  end

  def test_should_check_new_dir_exists
    client = clients(:digitech)
    category = Category.create(:name => 'does-exist')
    dir = @firm.store_dir + "/" + client.name.downcase + "/" + category.name.downcase

    Dir.mkdir(dir, 0775) unless File.exists?(dir)

    assert category.new_dir_exists?(@firm)

    Dir.rmdir(dir)
  end
=begin
  def test_should_check_new_dir_does_not_exist
    category = Category.create(:name => 'does_not_exist')
    assert !category.new_dir_exists?(@firm)
  end
=end


end
