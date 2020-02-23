defmodule CdmRecordEnrichers.FieldFormattersTest do
  import CdmRecordEnrichers.FieldFormatters
  use ExUnit.Case
  import ExUnit.CaptureLog

  # Remove semicolons
  describe "when text has a semicolon" do
    test "it removes semicolons" do
      assert remove_semicolon("foo bar") == "foo bar"
      assert remove_semicolon("foo; bar") == "foo bar"
    end
  end

  describe "when text has no semicolon" do
    test "it does nothing" do
      assert remove_semicolon("foo bar") == "foo bar"
    end
  end

  # Convert values to JSON
  describe "when the value is a map and converting to json" do
    test "it encodes it into json" do
      assert json_encode(%{foo: :bar}) == "{\"foo\":\"bar\"}"
    end
  end

  describe "when the value is a list and converting to json" do
    test "it encodes it into json" do
      assert json_encode([%{foo: :bar}]) == "[{\"foo\":\"bar\"}]"
    end
  end

  # Convert values to integers
  describe "when the value is a string and converting to an integer" do
    test "it converts the string into an integer" do
      assert to_i(2) == 2
    end
  end

  describe("when given an invalid string value to convert into an integer") do
    test "it returns nil" do
      assert capture_log(fn ->
               assert(to_i("foo") == nil)
               to_i("foo")
             end) =~ "ArgumentError: cannot convert foo to integer"
    end
  end

  describe "when the value is already an integer and converting to an integer" do
    test "it returns the valye" do
      assert to_i(5) == 5
    end
  end

  describe "when the value is not a string or an integer and converting to an integer" do
    test "it returns nil" do
      assert to_i(%{}) == nil
      assert to_i([]) == nil
      assert to_i(key: "val") == nil
      assert to_i('') == nil
      assert to_i(true) == nil
    end
  end

  # Convert maps to nils
  describe "when the value is a map and converting to nil" do
    test "it returns nil" do
      assert map_to_nil(%{foo: "bar"}) == nil
    end
  end

  describe "when the value is not a map and converting to nil" do
    test "it returns the value" do
      assert map_to_nil("foo") == "foo"
      assert map_to_nil([1, 2, 3]) == [1, 2, 3]
    end
  end

  # Titleize
  describe "when titleizing a list of strings" do
    test "it titleizes each string" do
      assert titleize(["foo", "bar"]) == ["Foo", "Bar"]
    end
  end

  describe "when titleizing an invalid list" do
    test "it returns the value and logs the error" do
      assert capture_log(fn ->
               assert titleize([:foo, :bar]) === [:foo, :bar]
               titleize([:foo, :bar])
             end) =~ "Attempted but failed to titlize :bar"
    end
  end

  describe "when titleizing a single string" do
    test "it titleizes it" do
      assert titleize("blerg") == "Blerg"
    end
  end

  # Join or ignore
  describe "when joining a list" do
    test "it joins the list with semicolons" do
      assert join([1, 2, 3]) == "1;2;3"
    end
  end

  describe "when attemtping to join a non-list" do
    test "it returns the value" do
      assert join(%{foo: :bar}) == %{foo: :bar}
      assert join("") == ""
      assert join('foo') == "102;111;111"
      assert join(true) == true
    end
  end

  # Split or ignore
  describe "when splittig a string" do
    test "it splits the list on semicolons" do
      assert split("1;2;3") == ["1", "2", "3"]
      assert split("") == [""]
    end
  end

  describe "when attemtping to split a non-string" do
    test "it returns the value" do
      assert split(%{foo: :bar}) == %{foo: :bar}
      assert split('foo') == 'foo'
      assert join(true) == true
      assert split([1, 2, 3]) == [1, 2, 3]
    end
  end

  # Record ID
  test "it transforms an cdm id to a solr id" do
    assert to_solr_id("foobar/123") == "foobar:123"
  end
end
