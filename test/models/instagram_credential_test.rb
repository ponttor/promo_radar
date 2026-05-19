require "test_helper"

class InstagramCredentialTest < ActiveSupport::TestCase
  test "valid with username and session_json" do
    c = InstagramCredential.new(username: "monitor_bot", session_json: "{}", active: true)
    assert c.valid?
  end

  test "invalid without username" do
    c = InstagramCredential.new(session_json: "{}", active: true)
    assert_not c.valid?
    assert_includes c.errors[:username], "can't be blank"
  end

  test "invalid without session_json" do
    c = InstagramCredential.new(username: "monitor_bot", active: true)
    assert_not c.valid?
    assert_includes c.errors[:session_json], "can't be blank"
  end

  test "active scope returns only active credentials" do
    InstagramCredential.create!(username: "a", session_json: "{}", active: true)
    InstagramCredential.create!(username: "b", session_json: "{}", active: false)
    active_usernames = InstagramCredential.active.pluck(:username)
    assert_includes active_usernames, "a"
    assert_not_includes active_usernames, "b"
  end
end
