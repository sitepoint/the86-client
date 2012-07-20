The86::Client
=============

Ruby client for "The 86" conversation API server.

Usage
-----

```ruby
# The domain running The 86 discussion server.
The86::Client.domain = "the86.yourdomain.com"

# HTTP Basic Auth credentials allocated for your API client.
The86::Client.credentials = ["username", "password"]

# Create an end-user account:
user = The86::Client::User.create(name: "John Citizen")
oauth_token = user.access_tokens.token

# Create a new conversation:
conversation = The86::Client.site("example").conversations.create(
  content: "Hello world!",
  oauth_token: oauth_token
)

# Reply as another user:
user = The86::Client::User.create(name: "Jane Taxpayer")
conversation.posts.first.reply(
  content: "I concur!",
  oauth_token: user.access_tokens.first.token
)

# Follow up to a conversation:
user = The86::Client::User.create(name: "Joe Six-pack")
conversation.follow_up(
  content: "What are you guys talking about?",
  oauth_token: user.access_tokens.first.token
)
```

TODO
----

* Expose user access token in newly created User object.


Licence
-------

(c) SitePoint Pty Ltd, 2012.  All rights reserved.
