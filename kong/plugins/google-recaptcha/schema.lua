local PLUGIN_NAME = "google-recaptcha"

return {
  name = PLUGIN_NAME,
  fields = {
    {
      config = {
        type = "record",
        fields = {
          {
            site_key = {
              type = "string",
              required = true,
            }
          },
          {
            secret_key = {
              type = "string",
              required = true,
            },
          },
          {
            version = {
              type = "string",
              default = "v2",
              one_of = {
                "v2",
                "v3",
              },
            },
          },
          {
            score_threshold = {
              type = "number",
              default = 0.8,
              between = {
                0,
                1
              },
            },
          },
          {
            api_server = {
              type = "string",
              default = "https://www.google.com/recaptcha/api/siteverify",
              required = false,
            },
          },
          {
            captcha_response_name = {
              type = "string",
              default = "g-recaptcha-response",
              required = false,
            },
          },
        },
      },
    },
  },
}

