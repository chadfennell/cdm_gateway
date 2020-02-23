defmodule CdmRecordEnrichers.FieldTest do
  import CdmRecordEnrichers.Field
  use ExUnit.Case

  @dest_record %{id: "123"}

  test "it populates and merges a field into the dest_record" do
    assert field(@dest_record, :foo, :bar) == %{foo: :bar, id: "123"}
  end

  describe "when a value is empty" do
    test "skips the field" do
      assert field(@dest_record, :foo, %{}) == @dest_record
      assert field(@dest_record, :foo, []) == @dest_record
      assert field(@dest_record, :foo, nil) == @dest_record
      assert field(@dest_record, :foo, "") == @dest_record
    end
  end

  describe "when a string has leading/trailing whitespace" do
    test "it trims the whitespace" do
      assert field(@dest_record, :foo, " foo ") == %{foo: "foo", id: "123"}
    end
  end

  describe "when list of a strings have leading/trailing whitespace" do
    test "it trims the witespace from each string" do
      assert field(@dest_record, :foo, [" foo "]) == %{id: "123", foo: ["foo"]}
    end
  end

  describe "when the value is a list of non-strings" do
    test "it populates the value of the field" do
      assert field(@dest_record, :foo, [%{foo: :bar}]) == %{id: "123", foo: [%{foo: :bar}]}
    end
  end
end
