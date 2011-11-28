class CategoriesController < ApplicationController
  before_filter :login_required

  def index
    @categories = Category.paginate(:page => params[:page], :per_page => 10, :order => "upper(name)", :conditions => { :firm_id => current_firm.id })    
  end

  def new
    @category = Category.new
    @category.firm_id = current_firm.id
  end

  def create
    @category = Category.new(params[:category])

    if @category.save
      flash[:notice] = "Category created successfully!"
      redirect_to categories_path
    else
      render :new
    end
  end

  def edit
    @category = Category.find(params[:id])
  end

  def update
    @category = Category.find(params[:id])
    @oldcat = @category.name
    
    if @category.update_attributes(params[:category])
      @category.move_dir(current_firm,@oldcat)
      flash[:notice] = "Category updated successfully!"
      redirect_to categories_path
    else
      render :edit
    end
  end

  def destroy
    @category = Category.find(params[:id])
    @category.delete
    flash[:notice] = "Category deleted successfully!"
    redirect_to categories_path
  end
end
