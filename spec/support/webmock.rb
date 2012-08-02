require "json"
require "webmock/minitest"

WebMock.disable_net_connect!

##
# WebMock request expectations.
module RequestExpectations

  def self.included(klass)
    klass.before { @expected_requests = [] }
    klass.after { @expected_requests.each { |sr| assert_requested(sr) } }
  end

  def stub_and_assert_request(*parameters)
    stub_request(*parameters).tap do |request|
      @expected_requests << request
    end
  end

  def expect_request(options)
    rack_method_override!(options, :patch)

    url = options.fetch(:url)
    method = options.fetch(:method)
    request_body = options[:request_body]
    response_body = options[:response_body]
    request_headers = options[:request_headers]

    request = {}
    request[:body] = request_body if request_body
    request[:headers] = request_headers if request_headers

    response = {status: options[:status] || 200}
    response[:body] = JSON.generate(response_body) if response_body

    stub_and_assert_request(method, url).
      with(request).
      to_return(response)
  end

  private

  # Rewrite the expectations for Rack::MethodOverride.
  # See: https://github.com/rack/rack/blob/master/lib/rack/methodoverride.rb
  # For example an expectation of a PATCH request maps to an actual
  # expectation of a POST request with PATCH in an override header.
  def rack_method_override!(options, *methods)
    if methods.include?(options[:method])
      options[:request_headers] ||= {}
      options[:request_headers]["X-Http-Method-Override"] = options[:method]
      options[:method] = :post
    end
  end

end

MiniTest::Spec.send(:include, RequestExpectations)
