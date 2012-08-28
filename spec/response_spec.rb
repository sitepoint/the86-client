require_relative "spec_helper"

module The86::Client
  describe Response do

    it "stores status, headers, data" do
      r = Response.new(201, {"X-Test" => "test"}, {id: 4})
      r.status.must_equal 201
      r.headers.must_equal("X-Test" => "test")
      r.data.must_equal(id: 4)
    end

    describe "#links" do
      let(:response) { Response.new(200, {"Link" => links}, nil) }
      let(:links) { [
        %{<https://example.org/page3>; rel="next"},
        %{<http://example.org/page1?a=b>; rel="prev"},
      ] }

      it "exposes RFC 5988 link headers" do
        response.links[:next].must_equal "https://example.org/page3"
        response.links[:prev].must_equal "http://example.org/page1?a=b"
        response.links[:test].must_equal nil
      end
    end

  end
end
