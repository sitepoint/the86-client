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

      it "is inequal to another type of object" do
        resource.new(id: 1, code: "A").wont_equal false
      end
    end

    describe "#has_many" do
      it "returns the same instance of ResourceCollection" do
        class Widget < Resource
          attribute :name, String
        end
        resource = Class.new(Resource) do
          attribute :id, Integer
          has_many :widgets, ->{ Widget }
        end
        i = resource.new widgets: [{ name: "Knob" }]
        widgets = i.widgets
        widgets.send(:records).size.must_equal 1
        i.widgets << Widget.new(name: "Flange")
        widgets.send(:records).size.must_equal 2
      end
    end

    describe "#accepts_nested_attributes_for" do
      class Widget < Resource
        attribute :name, String
      end

      resource = Class.new(Resource) do
        attribute :id, Integer
        has_many :widgets, -> { Widget }
        accepts_nested_attributes_for :widgets
      end

      it "includes nested items" do
        resource.
          new(id: 123, widgets: [{ name: "Knob" }, { name: "Flange" }]).
          sendable_attributes[:widgets].
          map{|widget| widget.attributes }.
          must_equal([{ name: "Knob" }, { name: "Flange" }])
      end
    end
  end
end
