The86::Client
=============

Ruby client for "The 86" conversation API server.

Uses [Faraday][1] for HTTP transport, JSON encoding/decoding etc.

Uses [Virtus][2] for DataMapper-style object attribute declaration.

Uses [MiniTest][3] and [WebMock][4] for unit/integration testing (run `rake`).


[1]: https://github.com/technoweenie/faraday
[2]: https://github.com/solnic/virtus
[3]: https://github.com/seattlerb/minitest
[4]: https://github.com/bblimke/webmock


Get Code, Run Tests
-------------------

    git clone REPO_PATH
    cd the86-client
    bundle install
    bundle exec rake


Install the Gem
---------------

    gem install the86-client


Add to a Project
----------------

    echo 'gem "the86-client"' >> Gemfile
    bundle


Usage
-----

```ruby
# The domain running The 86 discussion server.
The86::Client.domain = "the86.yourdomain.com"

# HTTP Basic Auth credentials allocated for your API client.
The86::Client.credentials = ["username", "password"]

# Create an end-user account:
user = The86::Client.users.create(name: "John Citizen")
oauth_token = user.access_tokens.first.token

# Create a new conversation:
conversation = The86::Client.group("example").conversations.create(
  content: "Hello world!",
  oauth_token: oauth_token
)

# Reply as another user:
user = The86::Client.users.create(name: "Jane Taxpayer")
conversation.posts.first.reply(
  content: "I concur!",
  oauth_token: user.access_tokens.first.token
)

# Follow up to a conversation:
user = The86::Client.users.create(name: "Joe Six-pack")
conversation.posts.create(
  content: "What are you guys talking about?",
  oauth_token: user.access_tokens.first.token
)

# List conversations:
conversations = The86::Client.group("example").conversations
second_page = conversations.more
third_page = second_page.more
third_page.each { |conversation| p conversation }

# Check for updates:
group = The86::Client.group("example")
conversations = group.conversations.with_parameters(
  posts_since: time.iso8601,
  without_user: 64,
)

# Like!
post = group.conversations.first.posts.first
post.likes.create(oauth_token: oauth_token)
likes = post.load.likes
puts "Liked by #{likes.count} people"
likes.each { |like| puts "* #{like.user.name}" }
```


Licence
-------

(c) SitePoint, 2012, MIT license.
