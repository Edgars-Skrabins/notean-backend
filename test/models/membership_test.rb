require "test_helper"

class MembershipTest < ActiveSupport::TestCase
  setup do
    @team = Team.create!(name: "Engineering", password: "supersecret")
    @alice = User.create!(email: "alice@example.com", username: "alice", password: "supersecret")
    @bob = User.create!(email: "bob@example.com", username: "bob", password: "supersecret")
  end

  test "defaults to the user role" do
    membership = Membership.create!(team: @team, user: @alice)

    assert_equal "user", membership.role
  end

  test "accepts admin and owner roles" do
    admin = Membership.create!(team: @team, user: @alice, role: "admin")
    owner = Membership.create!(team: @team, user: @bob, role: "user")

    assert admin.admin?
    assert_not owner.admin?
  end

  test "rejects a role outside user, admin, owner" do
    assert_raises(ArgumentError) do
      Membership.new(team: @team, user: @alice, role: "superadmin")
    end
  end

  test "only one owner is allowed per team" do
    Membership.create!(team: @team, user: @alice, role: "owner")

    error = assert_raises(ActiveRecord::RecordNotUnique) do
      Membership.create!(team: @team, user: @bob, role: "owner")
    end
    assert_match(/unique/i, error.message)
  end

  test "the same team can have an owner and separate admins" do
    Membership.create!(team: @team, user: @alice, role: "owner")
    admin = Membership.create!(team: @team, user: @bob, role: "admin")

    assert admin.persisted?
  end

  test "a user can own more than one team" do
    other_team = Team.create!(name: "Design", password: "supersecret")
    Membership.create!(team: @team, user: @alice, role: "owner")
    second_ownership = Membership.create!(team: other_team, user: @alice, role: "owner")

    assert second_ownership.persisted?
  end
end
