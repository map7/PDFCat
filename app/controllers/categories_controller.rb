class CategoriesController < ApplicationController
  before_filter :login_required

  def index
    @categories = Category.with_conditions(current_firm.id, params[:page])
  end

  def new
    @category = Category.new(firm_id: current_firm.id)
  end

  def create
    @category = Category.new(params[:category])
    @category.firm_id = current_firm.id

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

    # If there are pdfs in the category only admin should be able to move them.
    # This is due to the interface waiting around until the move has been done, which can
    # take a long time.
    if @category.pdfs_total == 0 || current_user.is_admin
      
      @oldcat = @category.name
      @category.attributes = params[:category]
      
      if @category.valid?
        @category.move_dir
        @category.update_attributes(params[:category])
      end

      if @category.errors.count > 0
        render :edit
      else
        flash[:notice] = "Category updated successfully!"
        redirect_to categories_path
      end
    else
      flash[:error] = "Category can only be updated by admin!"
      render :edit
    end
  end

  def destroy
    @category = Category.find(params[:id])
    if @category.destroy
      flash[:notice] = "Category deleted successfully!"
    else
      flash[:error] = @category.errors.full_messages.to_sentence # Convert error messages.
    end
    redirect_to categories_path
  end
end
