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
  instance = env.params.json["instance"]
  if instance.is_a?(Hash)
    lease_info = instance.fetch("leaseInfo") if instance.is_a?(Hash)
    if lease_info.is_a?(Hash)
      lease_info["registrationTimestamp"] = Time.now.epoch_ms
      lease_info["lastRenewalTimestamp"] = Time.now.epoch_ms + 30_000
      lease_info["evictionTimestamp"] = Time.now.epoch_ms + 90_000
      lease_info["serviceUpTimestamp"] = Time.now.epoch_ms
    end

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
  appID = env.params.url["appID"]
  instanceID = env.params.url["instanceID"]

  instances = all_apps.fetch(appID, nil)
  instances.delete(instanceID) if instances

  env.response.status_code = 200
end

## PUT /eureka/apps/COOKIE/dorchester.ny.pivotallabs.com:cookie:9001?status=UP&lastDirtyTimestamp=1476707380570
put "/eureka/apps/:appID/:instanceID" do |env|
  appID = env.params.url["appID"]
  instanceID = env.params.url["instanceID"]

  instances = all_apps.fetch(appID, nil)
  instance = instances.fetch(instanceID, nil) if instances
  ## TODO: Check -- <lastDirtyTimestamp>1476707380570</lastDirtyTimestamp>
  ## https://github.com/Netflix/eureka/blob/4f24d9dcf90713b421f6c092fa63e707cbf74df3/eureka-core/src/main/java/com/netflix/eureka/resources/InstanceResource.java#L122

  ## Necessary
  ## https://github.com/Netflix/eureka/blob/4f24d9dcf90713b421f6c092fa63e707cbf74df3/eureka-core/src/main/java/com/netflix/eureka/registry/AbstractInstanceRegistry.java#L345

  instance["status"] = env.params.query["status"].to_s if instance.is_a?(Hash)

  lease_info = instance.fetch("leaseInfo") if instance.is_a?(Hash)
  if lease_info.is_a?(Hash)
    lease_info["lastRenewalTimestamp"] = Time.now.epoch_ms + 30_000
    lease_info["evictionTimestamp"] = Time.now.epoch_ms + 90_000
    lease_info["serviceUpTimestamp"] = Time.now.epoch_ms
  end

  env.response.status_code = 200
end

get "/eureka/apps" do |env|
  env.response.status_code = 200

  applications = Array(Hash(String, JSON::Type)).new(0)
  statuses = Hash(String, UInt32).new(0_u32)
  all_apps.each do |name, instances|
    application = { "name" => name, "instance" => instances.values }
    applications << application
    instances.each do |instance|
      status = instance.fetch("status") if instance.is_a?(Hash)
      statuses[status] += 1 if status.is_a?(String)
    end
  end

  apps_hashcode = statuses.keys.sort.map { |k| "#{k}_#{statuses[k]}" }.join("_") + "_"

  { "applications" => { "versions__delta" => 1, "apps_hashcode" => apps_hashcode, "application" => applications }}.to_xml
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
  p env.params.json # ["instance"]

  env.response.status_code = 200
end

get "/eureka/vips/:vipAddress" do |env|
  env.response.status_code = 200
end

get "/eureka/svips/:svipAddress" do |env|
  env.response.status_code = 200
end

Kemal.run
