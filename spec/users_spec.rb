require_relative "spec_helper"

module The86::Client

  describe "Users" do

    describe "creating a user" do
      it "is successful with 200 OK" do
        expect_create_user(response_body: {id: 1, name: "John Appleseed"})
        user = The86::Client.users.create(name: "John Appleseed")
        user.id.must_be_instance_of Fixnum
        user.name.must_equal "John Appleseed"
      end

      it "raises ValidationFailed for 422 response" do
        expect_create_user(status: 422, request_body: {name: ""})
        ->{ The86::Client.users.create(name: "") }.must_raise ValidationFailed
      end

      it "raises Unauthorized for 401 response" do
        expect_create_user(status: 401, request_body: {name: "Test"})
        ->{ The86::Client.users.create(name: "Test") }.must_raise Unauthorized
      end
    end

    describe "updating a user (may not be supported by server)" do
      it "PATCHes users/:id" do
        time_before = DateTime.now - 86400
        time_after = DateTime.now
        expect_request(
          url: "https://user:pass@example.org/api/v1/users/5",
          method: :patch,
          status: 200,
          request_body: {name: "New Name"},
          response_body: {id: 5, name: "New Name", updated_at: time_after}
        )
        user = User.new(
          id: 5,
          name: "Old Name",
          updated_at: time_before
        )
        user.name = "New Name"
        user.updated_at.to_s.must_equal time_before.to_s
        user.save
        user.updated_at.to_s.must_equal time_after.to_s
      end
    end

    describe "listing users (may not be supported by server)" do
      it "returns collection of users" do
        expect_request(
          url: "https://user:pass@example.org/api/v1/users",
          method: :get,
          status: 200,
          response_body: [{id: 4, name: "Paul"}, {id: 8, name: "James"}]
        )
        users = The86::Client.users
        users.to_a.length.must_equal 2
        users.first.name.must_equal "Paul"
      end
    end

    def expect_create_user(options = {})
      expect_request({
        url: "https://user:pass@example.org/api/v1/users",
        method: :post,
        status: 201,
      }.merge(options))
    end

  end

end
