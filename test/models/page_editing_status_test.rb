require "test_helper"

class PageEditingStatusTest < ActiveSupport::TestCase
  include ActionCable::TestHelper

  setup do
    @previous_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    @user = Struct.new(:id, :username).new(1, "alice")
  end

  teardown do
    Rails.cache = @previous_cache
  end

  test "read returns nil when nothing has been cached" do
    assert_nil PageEditingStatus.read(42)
  end

  test "start caches the editing user and broadcasts it" do
    assert_broadcast_on("page_editing_42", editing: { id: 1, username: "alice" }) do
      PageEditingStatus.start(42, @user)
    end

    assert_equal({ user_id: 1, username: "alice" }, PageEditingStatus.read(42))
  end

  test "stop clears the cache and broadcasts nil when the current editor stops" do
    PageEditingStatus.start(42, @user)

    assert_broadcast_on("page_editing_42", editing: nil) do
      PageEditingStatus.stop(42, @user)
    end

    assert_nil PageEditingStatus.read(42)
  end

  test "stop does nothing when a different user attempts to stop" do
    PageEditingStatus.start(42, @user)
    other_user = Struct.new(:id, :username).new(2, "bob")

    assert_no_broadcasts("page_editing_42") do
      PageEditingStatus.stop(42, other_user)
    end

    assert_equal({ user_id: 1, username: "alice" }, PageEditingStatus.read(42))
  end
end
