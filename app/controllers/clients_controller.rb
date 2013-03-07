class ClientsController < ApplicationController

  before_filter :login_required

  make_resourceful do
    actions :all, :except => :destroy

    before :index do
      @clients = Client.paginate(:all,
                                 :order => 'upper(clients.name)',
                                 :page => params[:page],
                                 :per_page => 10,
                                 :conditions => search_conditions,
                                 :joins => :firm)
    end

    before :create do
      @client.firm_id = current_firm.id
    end

    before :update do
      @oldname = @client.name
    end

    after :update do
      # Move the directory.
      @client.move_dir(current_firm, @oldname)
    end

    response_for :create, :update do
      redirect_to :action => "index"
    end
  end

  def destroy
    @client = Client.find(params[:id])
    if @client.destroy
      flash[:notice] = "Client deleted successfully!"
    else
      flash[:error] = @client.errors.full_messages.to_sentence # Convert error messages.
    end
    redirect_to clients_path
  end

  protected
  def search_conditions
    name = "%%#{params[:client]}%%"

    cond_strings = returning([]) do |strings|
      strings << "firms.id = #{current_firm.id}"
      strings << "clients.name ilike '#{name}'" unless params[:client].blank?
    end

    if cond_strings.any?
      [ cond_strings.join(' and '), cond_strings ]
    else
      nil
    end
  end

end
