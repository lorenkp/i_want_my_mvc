require 'webrick'
require_relative '../lib/my_mvc'

describe Params do
  before(:all) do
    class UsersController < ControllerBase
      def index
      end
    end
  end
  after(:all) { Object.send(:remove_const, "UsersController") }

  let(:req) { WEBrick::HTTPRequest.new(Logger: nil) }
  let(:res) { WEBrick::HTTPResponse.new(HTTPVersion: '1.0') }
  let(:users_controller) { UsersController.new(req, res) }

  it "handles an empty request" do
    expect { Params.new(req) }.to_not raise_error
  end

  context "query string" do
    it "handles single key and value" do
      req.query_string = "key=val"
      params = Params.new(req)
      expect(params["key"]).to eq("val")
    end

    it "handles multiple keys and values" do
      req.query_string = "key=val&key2=val2"
      params = Params.new(req)
      expect(params["key"]).to eq("val")
      expect(params["key2"]).to eq("val2")
    end

    it "handles nested keys" do
      req.query_string = "user[address][street]=main"
      params = Params.new(req)
      expect(params["user"]["address"]["street"]).to eq("main")
    end

    it "handles multiple nested keys and values" do
      req.query_string =  "user[fname]=rebecca&user[lname]=smith"
      params = Params.new(req)
      expect(params["user"]["fname"]).to eq("rebecca")
      expect(params["user"]["lname"]).to eq("smith")
    end
  end

  context "post body" do
    it "handles single key and value" do
      allow(req).to receive(:body) { "key=val" }
      params = Params.new(req)
      expect(params["key"]).to eq("val")
    end

    it "handles multiple keys and values" do
      allow(req).to receive(:body) { "key=val&key2=val2" }
      params = Params.new(req)
      expect(params["key"]).to eq("val")
      expect(params["key2"]).to eq("val2")
    end

    it "handles nested keys" do
      allow(req).to receive(:body) { "user[address][street]=main" }
      params = Params.new(req)
      expect(params["user"]["address"]["street"]).to eq("main")
    end

    it "handles multiple nested keys and values" do
      allow(req).to receive(:body) { "user[fname]=rebecca&user[lname]=smith" }
      params = Params.new(req)
      expect(params["user"]["fname"]).to eq("rebecca")
      expect(params["user"]["lname"]).to eq("smith")
    end
  end

  context "route params" do
    it "handles route params" do
      params = Params.new(req, {"id" => 5, "user_id" => 22})
      expect(params["id"]).to eq(5)
      expect(params["user_id"]).to eq(22)
    end
  end

  context "indifferent access" do
    it "responds to string and symbol keys when stored as a string" do
      params = Params.new(req, {"id" => 5})
      expect(params["id"]).to eq(5)
      expect(params[:id]).to eq(5)
    end
    it "responds to string and symbol keys when stored as a symbol" do
      params = Params.new(req, {:id => 5})
      expect(params["id"]).to eq(5)
      expect(params[:id]).to eq(5)
    end
  end
end

describe 'ControllerBase#initialize' do
  before(:all) do
    class UsersController < ControllerBase
      def index
      end
    end
  end

  after(:all) { Object.send(:remove_const, "UsersController") }

  let(:req) { WEBrick::HTTPRequest.new(Logger: nil) }
  let(:res) { WEBrick::HTTPResponse.new(HTTPVersion: '1.0') }
  let(:users_controller) { UsersController.new(req, res) }

  context '#initialize' do
    it "sets params var to new Params object" do
      expect(users_controller.params).to be_instance_of(Params)
    end
  end
end

