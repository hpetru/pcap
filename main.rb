require 'pry'
require 'rest-client'
require 'nokogiri'

REGEXP = /(JSESSIONID|AUTHCODE)=([^;]+)/
APP_URI = 'http://odnoklassniki.ru'

sessions = []
in_file = 'cookies.txt'
users = []

File.open('users.json', 'r') do |file|
  users_json = file.read
  users_json = '[]' if users_json.empty?

  users = JSON.parse(users_json) || []
end

File.open(in_file, 'r') do |file|
  file.each_line do |line|
    cookies = line.scan(REGEXP)

    next unless cookies.flatten.include?("JSESSIONID")
    next unless cookies.flatten.include?('AUTHCODE')

    cookie = {}
    cookies.each  { |k, v| cookie[k] = v }

    cookie_exist = sessions.select{ |hash| hash['JSESSIONID'] == cookie['JSESSIONID'] }
    sessions << cookie if cookie_exist.empty?
  end
end

sessions.each do |session|
  jsession_id = session["JSESSIONID"]
  auth_code = session["AUTHCODE"]

  user_exist = users.select { |hash| hash["session_id"] == jsession_id }
  next unless user_exist.empty?

  cookies = { 
    "JSESSIONID" => jsession_id,
    "AUTHCODE" => auth_code
  }
  resp = RestClient.get(APP_URI, cookies: cookies)
  doc = Nokogiri::HTML(resp)

  name = doc.css('.mctc_name  .mctc_nameLink.bl')
  next if name.empty?
  name = name.text

  avatar = doc.css('.lcTc_avatar_user  img')
  avatar = avatar.first['src']

  users << {
    "name" => name,
    "avatar" => avatar,
    "session_id" => jsession_id,
    "auth_code" => auth_code
  }

end

File.open('users.json', 'w') do |file|
  users_json = users.to_json
  file.write(users_json)
end
