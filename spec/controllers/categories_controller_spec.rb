require 'spec_helper'

describe CategoriesController do
  context "As a logged in user" do
    before do
      login_user
    end

    describe "#index" do
      it "should render index" do
        current_firm = mock_model(Firm, :id => 1)
        controller.stub!(:current_firm).and_return(current_firm)
        get :index
        response.should render_template('index')
      end
    end

    describe "machinist" do
      it "should create a user" do
        user = User.make
        user.login.should == "map7"
      end
    end
  end

end
