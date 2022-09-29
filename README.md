# Kong plugin google recaptcha validation

A kong plugin that handle googles recaptcha validation.

### Description

By adding this plugin to kong route or service this plugins will automatically extract the google recaptcha response
from the request header or boyd then calls google validation endpoint. then depending on the validation status either
forward the call to the upstream or return a 403 to the client.

## Getting Started

### Dependencies

* This plugin is written on lua version 5.1 or higher.
* luasec (version )
* luasocket (version )
* lua-cjson (version )

### Installing

This plugin is provided as luarocks module :

```shell
luarocks install kong-plugin-google-recaptcha
```

To add this plugin to kong
check : [(un)Installing custom kong plugin](https://docs.konghq.com/gateway/latest/plugin-development/distribution/)

## plugin configuration

this plugin can be configured on routes level, service level or globally

### example

**Example to configure google recaptcha V2**

Enable on a service

```yaml
plugins:
  - name: google-recaptcha
    service: SERVICE_NAME
    config:
      site_key: the_google_recaptcha_site_key
      secret_key: the_google_recaptcha_site_secret
```

Enable on a route

```yaml
plugins:
  - name: google-recaptcha
    route: ROUTE_NAME
    config:
      site_key: the_google_recaptcha_site_key
      secret_key: the_google_recaptcha_site_secret
```

Enable globally

```yaml
plugins:
  - name: google-recaptcha
    config:
      site_key: the_google_recaptcha_site_key
      secret_key: the_google_recaptcha_site_secret
```

### Parameters

| Form Parameter                                  | Type                                | Description                                                                                                   |
|-------------------------------------------------|-------------------------------------|---------------------------------------------------------------------------------------------------------------|
| name <br/>  `required`                          | `string`                            | The name of the plugin, in this case google-recaptcha .                                                       |
| config.site_key <br/>  `required`               | `string`                            | The site key as provided by google recaptcha                                                                  |
| config.secret_key <br/>  `required`             | `string`                            | The site secret key as provided by google recaptcha                                                           |                                                      |
| config.version <br/>  `optional`                | `string` <br/> can be only v2 or v3 | the recaptcha version (only V2 checkbox and V3 are supported  <br/> default: `V2`                             |
| config.score_threshold <br/>  `optional`        | `number` <br/> between 0 and 1      | The recaptcha version 3 score threshold  <br/> default: `0.8`                                                  |
| config.api_server <br/>   `optional`            | `string`                            | the endpoint to validate the response  <br/> default: `https://www.google.com/recaptcha/api/siteverify`       |
| config.captcha_response_name <br/>   `optional` | `string`                            | the header or body attribute name used to hold the captcha response value <br/> default: `g-recaptcha-response` |

> **_NOTE:_**  This plugin will search for the recaptcha response in the request header named as configured in the
> parameter `config.captcha_response_name` if note found it will check the body for an attribute with the same name if
> not
> provided neither in the headers nor the body the validation will fail

### How to run example locally

To run testing environment locally, run the following command (you will need docker, docker compose and of course git)

#### Step 01

```shell
git clone https://github.com/HK-Soft/kong-plugin-google-recaptcha.git
```

```shell
cd kong-plugin-google-recaptcha
```

#### Step 02

Add your site-key and secret-key to `simple-api.yaml`

replace the attribute `data-sitekey` in /spec/google-recaptcha-test.html with your site-key

#### step 03

build docker images (kong + node mock service)

```shell
docker compose build --no-cache
```

Run docker images (insomnia declarative configs generation + kong + node mock service)

```shell
docker compose up --force-recreate
```

Note: every time we run this two commands we build new images to avoid contamination between different executions

#### step 04

You need to serve the static html page /spec/google-recaptcha-test.html from the same server as configured at Google
recaptcha admin page (for localhost you can use vs code live server plugin), you can also use postman to call the
endpoints just don't forget to add the header or an attribute in the body named  `g-recaptcha-response`

- A kong container will be started at **localhost:8000**

- A node mock service will be started at **localhost:4000**

- This kong container will be configured with the following routes protected with the Google recaptcha
    - GET: /api/v2/users
    - POST: /api/v2/users

## Links

[Kong Develop Custom Plugins](https://docs.konghq.com/gateway/latest/plugin-development/)

[Plugin Development Kit](https://docs.konghq.com/gateway/3.0.x/plugin-development/pdk/)

[Google recaptcha](https://www.google.com/recaptcha/admin)

[Google recaptcha Enterprise](https://console.cloud.google.com/marketplace/product/google/recaptchaenterprise.googleapis.com)

## Help

Want to improve this project? Create a pull request with detailed changes / improvements! If approved you will be added
to the list of authors of this awesome project!

## Authors

* Abdeldjalil [HK-Soft](https://github.com/HK-Soft)

## Version History

* 0.1.0
    * support checkbox V2 recaptcha
    * support recaptcha on route level
    * support sending response in headers or body
    * support customizing the header name holding the recaptcha response
    * support customizing the body attribute name holding the recaptcha response
    * support V3 recaptcha
    * support recaptcha on service or globally (experimental)

## License

## Acknowledgments

Special thanks to Jeffry
L [paragasu](https://github.com/paragasu) [lua-recaptcha](https://github.com/paragasu/lua-recaptcha)

