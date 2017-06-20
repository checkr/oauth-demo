# oauth-demo

This repository contains a sample app that demonstrates OAuth integration as well as setting up webhooks and packages for your end users. See guide below for complete details.

### Setup
`bundle install`

#### Set environment variables

* Copy `.env.example` to `.env`
* Set variables as:
  * `CHECKR_CLIENT_ID='your client id'`
  * `CHECKR_CLIENT_SECRET='your secret key'`
  * `REDIRECT_URI='https://your-domain.com/oauth_callback'`

### Start webserver
`foreman start web`

Navigate to `http://localhost:5000` to see the demo app in action. We also recommend using incognito mode if you already have an existing Checkr account to test the sign up OAuth flow as well.

### Limitations
- Note that `REDIRECT_URI` must use the HTTPS protocol. If you are testing the app locally, `https://localhost` will not work unless you have a self-signed certificate. During development, we typically set `REDIRECT_URI='https://localhost:5000/oauth_callback'` and manually change the protocol to `http` in the browser once the redirect happens.

- Make sure that the webhook url you’re using is publicly available (e.g., we won’t be able to reach localhost). Optionally, you can use a service like RequestBin to do webhook development without setting up a server.
