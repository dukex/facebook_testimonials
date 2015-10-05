require 'sinatra'
require 'pry'
require 'base64'
require 'json'
require './lib/facebook'
require 'koala'
require 'mongoid'

Koala.config.api_version = 2.4

Mongoid.load!("./config/mongoid.yml", ENV['RACK_ENV'])

class Testimonial
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :from, class_name: "User"
  belongs_to :to, class_name: "User"

  field :body
end

class User
  include Mongoid::Document
  field :id
  field :name
  field :image_url
end

class DepoApp < Sinatra::Base

  use Rack::Session::Cookie, key: '_depo',
                             secret: 'rew'

  post '/' do
    data = Facebook.parse_signed_request(ENV['FACEBOOK_SECRET'], params[:signed_request])
    env['rack.session'][:current_user] = data["oauth_token"]

    headers \
      "X-Frame-Options" => "ALLOW-FROM https://apps.facebook.com"

    @appID = ENV['FACEBOOK_APP_ID']
    erb :app
  end

  get '/me' do
    content_type :json

    token = request.session[:current_user]
    @graph = Koala::Facebook::API.new(token, ENV['FACEBOOK_SECRET'])

    unless me = request.session[:me]
      request.session[:me] = me = @graph.get_object('me', fields: [:id, :name, :picture])

      me["image_url"] = me.delete("picture")["data"]["url"]

      if user = User.where(id: me["id"]).first
        user.update_attributes me
      else
        User.create! me
      end
    end

    { user: me }.to_json
  end

  get '/testimonials/:user_id' do
    content_type :json
    user = User.find(params[:user_id])
    testimonials = Testimonial.includes(:to, :from).where(to: user).all.as_json(only: [:id, :name, :image_url, :body], methods: [:to, :from])
    { testimonials: testimonials }.to_json
  end
end
