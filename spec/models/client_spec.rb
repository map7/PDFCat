require 'spec_helper'

describe Client do
  let(:client) {Client.make}

  describe "destroy" do
    context "with no pdfs attached" do
      it "deletes" do
        client.destroy
        lambda { Client.find(client.id) }.should raise_error(ActiveRecord::RecordNotFound)
      end
    end
    
    context "with pdfs attached" do
      before do
        client.pdfs << Pdf.make
      end
      
      it "should not delete" do
        client.destroy
        lambda { Client.find(client.id) }.should_not raise_error(ActiveRecord::RecordNotFound)        
      end

      it "adds an error" do
        client.destroy
        client.errors.count.should == 1
      end
    end
  end
end
