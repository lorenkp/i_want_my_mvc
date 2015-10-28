require 'webrick'
require_relative '../lib/my_mvc'

describe ControllerBase do
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

  describe "#render_template" do
    before(:each) do
      users_controller.render_template "somebody", "text/html"
    end

    it "sets the response content type" do
      expect(users_controller.res.content_type).to eq("text/html")
    end

    it "sets the response body" do
      expect(users_controller.res.body).to eq("somebody")
    end
  end

  describe "#redirect" do
    before(:each) do
      users_controller.redirect_to("http://www.google.com")
    end

    it "sets the header" do
      expect(users_controller.res.header["location"]).to eq("http://www.google.com")
    end

    it "sets the status" do
      expect(users_controller.res.status).to eq(302)
    end
  end
  describe "#render" do
    before(:each) do
      users_controller.render(:index)
    end

    it "renders the html of the index view" do
      expect(users_controller.res.body).to include("Users")
      expect(users_controller.res.body).to include("<h1>")
      expect(users_controller.res.content_type).to eq("text/html")
    end
  end
end
