require 'spec_helper'

describe CategoriesController do
  context "As a logged in user" do
    before do
      login_user
    end

    describe "#index" do
      it "should render index" do
        get :index
        response.should render_template('index')
      end
    end
  end
end
