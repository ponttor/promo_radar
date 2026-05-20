require "test_helper"

class InjectionGuardTest < ActiveSupport::TestCase
  test "inherits from ActiveHarness::Agent" do
    assert InjectionGuard < ActiveHarness::Agent
  end
end
