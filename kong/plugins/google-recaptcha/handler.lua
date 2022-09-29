local https = require "ssl.https"
local ltn12 = require "ltn12"
local json = require "cjson"

local plugin = {
  PRIORITY = 1000,
  VERSION = "0.1.0",
}

-- kong global variable
-- https://docs.konghq.com/gateway/latest/plugin-development/pdk/
local kong = kong

function valid(secret_key, api_server, g_captcha_res, remote_ip)

  if not secret_key then
    return nil, 'Missing required secret key'
  end

  if not api_server then
    return nil, 'Missing required api server'
  end
  if not g_captcha_res then
    return nil, 'Missing required g-captcha-response'
  end
  if not remote_ip then
    return nil, 'Missing require remote_ip'
  end

  local data = {
    secret = secret_key,
    response = g_captcha_res,
    remoteip = remote_ip
  }
  local encoded_url = encode_url(data)

  local response_body = {}

  local _, code, _ = https.request {
    url = api_server .. '?' .. encoded_url,
    method = 'POST',
    headers = {
      ["Content-Type"] = "application/json",
      ["Content-Length"] = 0
    },
    sink = ltn12.sink.table(response_body)
  }

  response_body = json.decode(table.concat(response_body))

  if not response_body and code ~= 200 then
    return nil
  end
  if not response_body.success then
    return false, response_body['error-codes']
  end

  return true, nil, response_body.score, response_body.action
end

-- encode string into escaped hexadecimal representation
-- from socket.url implementation
function escape(s)
  return (string.gsub(s, "([^A-Za-z0-9_])", function(c)
    return string.format("%%%02x", string.byte(c))
  end))
end

-- encode url
function encode_url(args)
  local params = {}
  for k, v in pairs(args) do
    table.insert(params, k .. '=' .. escape(v))
  end
  return table.concat(params, "&")
end

function plugin:access(config)

  kong.log.debug(
    string.format(
      "Validating a recaptcha secret :: version %s for site key %s at server %s using header name %s ",
      config.version,
      config.site_key,
      config.api_server,
      config.captcha_response_name
    )
  )
  -- get the client ip address
  local remote_ip = kong.client.get_ip()

  -- try to get the captcha response from the headers
  local g_captcha_response = kong.request.get_header(config.captcha_response_name)
  -- if no captcha response in the headers try the body
  if not g_captcha_response then
    local body, _, _ = kong.request.get_body();
    if body then
      g_captcha_response = body[tostring(config.captcha_response_name)]
    end
  end
  kong.log.debug(
    string.format("Validating a recaptcha secret :: retrieved captcha response %s ", g_captcha_response)
  )

  local status, errs, score, action = valid(
    config.secret_key,
    config.api_server,
    g_captcha_response,
    remote_ip
  )
  kong.log.inspect({ status, errs, score, action })
  if (not status) then
    kong.log.debug("Invalidate recaptcha response")
    return kong.response.error(403, "Access Forbidden", { ["Content-Type"] = "application/json", })
  elseif (config.version == "V3" and not config.score_threshold and score < config.score_threshold) then
    kong.log.debug("Invalidate recaptcha score value")
    return kong.response.error(403, "Access Forbidden", { ["Content-Type"] = "application/json", })
  end

end

return plugin
