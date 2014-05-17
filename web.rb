require 'sinatra'
require 'haml'
require 'json'
require 'active_support/core_ext/array'
require 'pry'
require 'cgi'

get '/' do
  @users = get_users
  @users = @users.in_groups(3, false)
  haml :index, layout: :base
end

def get_users
  users = []
  File.open('users.json') do |file|
    users_json = file.read
    unless users_json.empty?
      users = JSON.parse(users_json)
    end
  end
  users
end
