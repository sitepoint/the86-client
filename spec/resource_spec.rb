require_relative "spec_helper"

module The86::Client
  describe Resource do

    describe "equality" do
      resource = Class.new(Resource) do
        attribute :id, Integer
        attribute :code, String
      end

      parent_resource = Class.new(Resource) do
        attribute :id, Integer
      end

      it "is equal by attributes" do
        resource.new(id: 1, code: "A").
          must_equal resource.new(id: 1, code: "A")
      end

      it "is inequal by attributes" do
        resource.new(id: 2, code: "A").
          wont_equal resource.new(id: 1, code: "A")
      end

      it "is inequal by parent" do
        resource.new(code: "A", parent: parent_resource.new(id: 1)).
          wont_equal resource.new(code: "A", parent: parent_resource.new(id: 2))
      end
    end
  end
end
