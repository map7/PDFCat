require 'spec_helper'

describe ClientsController do
  context "As a logged in user" do
    before do
      login_user
      current_firm = mock_model(Firm, :id => 1)
      controller.stub!(:current_firm).and_return(current_firm)
    end

    describe "#destroy" do
      before do
        @client = Client.make
      end
      
      context "no pdfs attached" do 
        it "deletes a client" do
          lambda do 
            delete :destroy, :id => @client.id
          end.should change(Client, :count).from(1).to(0)
        end
        
        it "redirects to listing categories" do
          delete :destroy, :id => @client.id
          response.should redirect_to(clients_path)
        end

        it "displays flash message" do
          delete :destroy, :id => @client.id
          flash[:notice].should == "Client deleted successfully!"
        end
      end

      context "pdfs attached" do 
        it "displays error message" do
          @client.pdfs << Pdf.make
          delete :destroy, :id => @client.id
          flash[:error].should == "Cannot delete Client as there are 1 document(s) attached"
        end
      end
    end
  end
end
