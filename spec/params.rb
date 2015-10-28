require 'webrick'
require_relative '../lib/my_mvc'

describe Session do
  let(:req) { WEBrick::HTTPRequest.new(Logger: nil) }
  let(:res) { WEBrick::HTTPResponse.new(HTTPVersion: '1.0') }
  let(:cook) { WEBrick::Cookie.new('_my_mvc_', { xyz: 'abc' }.to_json) }

  it "deserializes json cookie if one exists" do
    req.cookies << cook
    session = Session.new(req)
    expect(session['xyz']).to eq('abc')
  end

  describe "#store_session" do
    context "without cookies in request" do
      before(:each) do
        session = Session.new(req)
        session['first_key'] = 'first_val'
        session.store_session(res)
      end

      it "adds new cookie with '_my_mvc_' name to response" do
        cookie = res.cookies.find { |c| c.name == '_my_mvc_' }
        expect(cookie).not_to be_nil
      end

      it "stores the cookie in json format" do
        cookie = res.cookies.find { |c| c.name == '_my_mvc_' }
        expect(JSON.parse(cookie.value)).to be_instance_of(Hash)
      end
    end

    context "with cookies in request" do
      before(:each) do
        cook = WEBrick::Cookie.new('_my_mvc_', { pho: "soup" }.to_json)
        req.cookies << cook
      end

      it "reads the pre-existing cookie data into hash" do
        session = Session.new(req)
        expect(session['pho']).to eq('soup')
      end

      it "saves new and old data to the cookie" do
        session = Session.new(req)
        session['machine'] = 'mocha'
        session.store_session(res)
        cookie = res.cookies.find { |c| c.name == '_my_mvc_' }
        h = JSON.parse(cookie.value)
        expect(h['pho']).to eq('soup')
        expect(h['machine']).to eq('mocha')
      end
    end
  end
end

describe ControllerBase do
  before(:all) do
    class UsersController < ControllerBase
    end
  end
  after(:all) { Object.send(:remove_const, "UsersController") }

  let(:req) { WEBrick::HTTPRequest.new(Logger: nil) }
  let(:res) { WEBrick::HTTPResponse.new(HTTPVersion: '1.0') }
  let(:users_controller) { UsersController.new(req, res) }

  describe "#session" do
    it "returns a session instance" do
      expect(users_controller.session).to be_a(Session)
    end

    it "returns the same instance on successive invocations" do
      first_result = users_controller.session
      expect(users_controller.session).to be(first_result)
    end
  end

  shared_examples_for "storing session data" do
    it "should store the session data" do
      users_controller.session['test_key'] = 'test_value'
      users_controller.send(method, *args)
      cookie = res.cookies.find { |c| c.name == '_my_mvc_' }
      h = JSON.parse(cookie.value)
      expect(h['test_key']).to eq('test_value')
    end
  end

  describe "#render_template" do
    let(:method) { :render_template }
    let(:args) { ['test', 'text/plain'] }
    include_examples "storing session data"
  end

  describe "#redirect_to" do
    let(:method) { :redirect_to }
    let(:args) { ['http://www.google.com'] }
    include_examples "storing session data"
  end
end