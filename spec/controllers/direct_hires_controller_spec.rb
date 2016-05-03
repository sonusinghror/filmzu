require 'spec_helper'

describe DirectHiresController do

  describe "GET 'accept_proposal'" do
    it "returns http success" do
      get 'accept_proposal'
      response.should be_success
    end
  end

  describe "GET 'decline_proposal'" do
    it "returns http success" do
      get 'decline_proposal'
      response.should be_success
    end
  end

end
