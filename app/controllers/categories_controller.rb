class CategoriesController < ApplicationController
  before_filter :login_required

  make_resourceful do
    actions :all

    before :index do
      @categories = Category.paginate(:page => params[:page], :per_page => 10, :order => "upper(name)", :conditions => { :firm_id => current_firm.id })
    end

    before :create do
      @category.firm_id = current_firm.id
    end

    before :update do
      # Save the old category before we save the new one.
      @oldcat = @category.name
    end

    after :update do
      # Move directory, if dir exists
      @category.move_dir(current_firm,@oldcat)
    end
    
    response_for :create, :update do
      redirect_to :action => "index"
    end
  end
end
