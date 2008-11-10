class ClientsController < ApplicationController

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :index }

  def index
logger.warn("Index...")
    @clients = get_listing()

  end

  def get_search
    logger.warn("get_search")
    logger.warn(params[:query])
    session[:client_search] = params[:query] unless params[:query].nil?

    searchclient = session[:client_search]
    logger.warn(searchclient)

    conditions = ["name ILIKE ?", "%#{searchclient}%"]

    @clients = Client.paginate(:page => params[:page],:conditions => conditions, :per_page => 10, :order => 'upper(name)')
  end

  def search
    @clients = get_search()

    render :action => 'index'
  end

  def show
    @client = Client.find(params[:id])
    @id = params[:id] # Used for shortcuts
  end

  def new
    @client = Client.new
  end

  def create
    @client = Client.new(params[:client])

    if @client.save
#      flash[:notice] = 'Client was successfully created.'
      @clients = get_listing()
      render :partial => "listing"
    else
      render :action => 'new', :layout => false, :status => '444'
    end
  end

  def edit
    @client = Client.find(params[:id])
  end

  def update
    @client = Client.find(params[:id])

    # Move directory, if dir exists
    # @newclient = Client.new(params[:client])
    # @newclient.name = @client.move_dir(@newclient.name)
    @oldname = @client.name


    # Store the data
    #if @client.errors.size == 0 and @client.update_attributes(params[:client])
    if @client.update_attributes(params[:client])

      # If successful in changing the client's details then,
      # Move the directory.
      @client.move_dir(@oldname)

#      flash[:notice] = 'Client was successfully updated.'
      @clients = get_listing()
      render :partial => "listing"
    else
      render :action => 'edit', :layout => false, :status => '444'
    end
  end

  def destroy
    Client.find(params[:id]).destroy
    redirect_to :action => 'index'
  end


  def get_listing
    if session[:client_search].nil?
      @clients = Client.paginate(:page => params[:page],:per_page => 10, :order => 'upper(name)')
    else
      @clients = get_search()
    end
  end

end
