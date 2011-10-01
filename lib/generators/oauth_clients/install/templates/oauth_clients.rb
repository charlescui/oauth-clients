#setting up oauth clients
#replace the value to yourself
OAuthClients::Provider.global_config = {
  "base" => {
    "realm" => "http://www.yourwebsite.com"
  },
  "tsina" => {
    "order" => 1,
    "key" => "your tsina app key",
    "secret" => "your tsina app secret"
  },
  "renren" => {
    "order" => 2,
    "key" => "your renren app key",
    "secret" => "your renren app secret",
    "options" => 
    {
      :scope => 'publish_feed,status_update'
    }
  }
}
