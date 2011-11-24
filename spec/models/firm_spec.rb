require 'spec_helper'

describe Firm do
  
  let(:firm) {Firm.make}
  
  describe "#categories_sorted" do
    it "should return sorted" do 
      cat1 = Category.make(:name => "building", :firm_id => firm.id)
      cat2 = Category.make(:name => "animal", :firm_id => firm.id)

      firm.categories_sorted.first.name.should == "animal"
    end
  end

  describe "#clients_sorted" do
    it "should return sorted" do 
      cat1 = Client.make(:name => "digitech", :firm_id => firm.id)
      cat2 = Client.make(:name => "acme", :firm_id => firm.id)

      firm.clients_sorted.first.name.should == "acme"
    end
  end
end
