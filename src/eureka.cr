require "./eureka/*"
require "kemal"
require "xml"

## See https://github.com/Netflix/eureka/wiki/Eureka-REST-operations


# Register new application instance_sizeof
# Input: JSON/XML payload HTTP
# Code: 204 on success
post "/eureka/apps/:appID" do |env|
  p env.params.json["instance"]
  puts env.params.json["instance"].to_xml
  env.response.status_code = 204
end

delete "/eureka/apps/:appID/:instanceID" do |env|
  env.response.status_code = 200
end

put "/eureka/apps/:appID/:instanceID" do |env|
  env.response.status_code = 200
end

get "/eureka/apps" do |env|
  env.response.status_code = 200
end

get "/eureka/apps/:appID" do |env|
  env.response.status_code = 200
end

get "/eureka/apps/:appID/:instanceID" do |env|
  env.response.status_code = 200
end

get "/eureka/instances/:instanceID" do |env|
  env.response.status_code = 200
end

put "/eureka/apps/:appID/:instanceID/status" do |env|
  ## ?value=OUT_OF_SERVICE
  ## ?value=UP
  env.response.status_code = 200
end

get "/eureka/vips/:vipAddress" do |env|
  env.response.status_code = 200
end

get "/eureka/svips/:svipAddress" do |env|
  env.response.status_code = 200
end

Kemal.run
