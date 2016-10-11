require "./eureka/*"
require "kemal"
require "xml"
require "to-xml"

## See https://github.com/Netflix/eureka/wiki/Eureka-REST-operations
all_apps = Hash(String, Hash(String, JSON::Type)).new

# Register new application instance_sizeof
# Input: JSON/XML payload HTTP
# Code: 204 on success
post "/eureka/apps/:appID" do |env|
  p env.params.json["instance"]
  puts env.params.json["instance"].to_s

  instance = env.params.json["instance"]
  if instance.is_a?(Hash)
    instanceId = instance.fetch("instanceId").to_s

    appID = env.params.url["appID"]
    instances = all_apps.fetch(appID) { all_apps[appID] = Hash(String, JSON::Type).new }
    instances[instanceId] = instance

    env.response.status_code = 204
  else
    env.response.status_code = 500
    { "error" => "instance was not a hash" }
  end
end

delete "/eureka/apps/:appID/:instanceID" do |env|
  env.response.status_code = 200
end

put "/eureka/apps/:appID/:instanceID" do |env|
  env.response.status_code = 200
end

get "/eureka/apps" do |env|
  env.response.status_code = 200

  applications = Array(Hash(String, JSON::Type)).new
  all_apps.each do |name, instances|
    application = { "name" => name, "instance" => instances.values }
    applications << application
  end
  { "applications" => { "versions__delta" => 1, "apps_hashcode" => "DOWN_1_UP_2_", "application" => applications }}.to_xml
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
