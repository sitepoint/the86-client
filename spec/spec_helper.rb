require "minitest/autorun"
require "turn"

require_relative "support/webmock"

$LOAD_PATH.unshift "./lib"
require "the86-client"

The86::Client.domain = "example.org"
The86::Client.credentials = ["user", "pass"]
