class CategoriesController < ApplicationController

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
#  verify :method => :post, :only => [ :destroy, :create, :update ],
#         :redirect_to => { :action => :index }

  def index
#    @category_pages, @categories = paginate(:categories, :order => 'upper(name)', :per_page => 10)
    @categories = Category.paginate(:page => params[:page], :per_page => 10, :order => "upper(name)")
    @no = -1  # Used for shorcuts
  end

  def show
    @category = Category.find(params[:id])
    @id = params[:id] # Used for shortcuts
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(params[:category])

    if @category.save
      flash[:notice] = 'Category was successfully created.'
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  def edit
    @category = Category.find(params[:id])
  end

  def update
    @category = Category.find(params[:id])

    # Move directory, if dir exists
    #@newcategory = Category.new(params[:category])
    #@newcategory.name = @category.move_dir(@newcategory.name)
  @oldcat = @category.name

    # Store the data
    #if @category.errors.size == 0 and @category.update_attributes(params[:category])
    if @category.update_attributes(params[:category])
    @category.move_dir(@oldcat)
    flash[:notice] = 'Category was successfully updated.'
    redirect_to :action => 'show', :id => @category
    else
    render :action => 'edit'
    end
  end

  def destroy
    Category.find(params[:id]).destroy
    redirect_to :action => 'index'
  end

  def show_item
  @category = Category.find(params[:id])
  #@id = params[:id]
  #render_text "test from controller " + @id
  #
  render_text "id: " + @category.id.to_s + "<br />" + "name: " + @category.name.to_s

  end

end
