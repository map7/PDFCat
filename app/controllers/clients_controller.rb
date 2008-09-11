class ClientsController < ApplicationController

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :index }

  def index

    if session[:client_search].nil?
      @clients = Client.paginate(:page => params[:page],:per_page => 10, :order => 'upper(name)')
    else
      search()
    end

  end

  def search
    session[:client_search] = params[:client] unless params[:client].nil?
    @searchclient = session[:client_search]
    @conditions = ["name ILIKE ?", "%#{@searchclient}%"]

    @clients = Client.paginate(:page => params[:page],:conditions => @conditions, :order => 'upper(name)', :per_page => 10)

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
      flash[:notice] = 'Client was successfully created.'
      redirect_to :action => 'index'
    else
      render :action => 'new'
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

      flash[:notice] = 'Client was successfully updated.'
      redirect_to :action => 'show', :id => @client
    else
      render :action => 'edit'
    end
  end

  def destroy
    Client.find(params[:id]).destroy
    redirect_to :action => 'index'
  end
end
