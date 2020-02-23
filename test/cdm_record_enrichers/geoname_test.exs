defmodule CdmRecordEnrichers.GeoNameTest do
  import CdmRecordEnrichers.Geoname
  use ExUnit.Case

  test "it converts a geonames uri to a geonames id and strips" do
    assert to_id("http://foo-bar/123/") == "123"
    assert to_id("http://foo-bar/123") == "123"
  end

  describe "looking for place information in a hash" do
    test "it processes place data" do
      assert place(%{
               "name" => "foo",
               "adminName1" => "bar",
               "adminName2" => "baz"
             }) == ["foo", "bar", "baz"]
    end
  end

  describe "looking for place information in a hash with Minnesota values" do
    test "it captures place information uniquely" do
      assert place(%{
               "name" => "Minnesota",
               "adminName1" => "bar",
               "adminName2" => "Minnesota"
             }) == ["bar"]
    end
  end

  describe "looking for place information in a hash with duplicate values" do
    test "it captures place information uniquely" do
      assert place(%{
               "name" => "baz",
               "adminName1" => "bar",
               "adminName2" => "bar"
             }) == ["baz", "bar"]
    end
  end

  describe "when attempting to populate place field with anything but a map value" do
    test "it ignores the field" do
      assert place("foo") == nil
      assert place(nil) == nil
      assert place(false) == nil
      assert place('foo') == nil
      assert place([1, 2]) == nil
    end
  end

  describe "if the value is not a coordinate map" do
    test "it ignores the field " do
      assert coordinates("foo") == nil
      assert coordinates(nil) == nil
      assert coordinates(false) == nil
      assert coordinates('foo') == nil
      assert coordinates([1, 2]) == nil
    end
  end

  describe "when either the lat or lng are not correctly populated" do
    test "it ignores the field" do
      assert coordinates(%{lat: 13, lng: false}) == nil
      assert coordinates(%{lat: false, lng: 2}) == nil
      assert coordinates(%{lat: 13}) == nil
      assert coordinates(%{lng: 2}) == nil
    end
  end

  describe "when both lat and lng are correctly populated" do
    assert coordinates(%{lat: "-12", lng: "33"}) == "-12,33"
  end
end
