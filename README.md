The86::Client
=============

Ruby client for "The 86" conversation API server.

Usage
-----

```ruby
The86::Client.domain = "the86.yourdomain.com"

site = Site.new(slug: "yourdomain")

user = The86::Client::User.create(name: "Test User")
conversation = Site.new(slug: "example").conversations.create(
  content: "Hello world!"
)

user = The86::Client::User.create(name: "Another User")
```

TODO
----

* HTTP Basic Auth for Users API.
* OAuth2 Bearer Token Auth for other APIs.


Licence
-------

(c) SitePoint Pty Ltd, 2012.  All rights reserved.
