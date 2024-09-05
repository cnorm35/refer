require "test_helper"

class Refer::ReferralCodeTest < ActiveSupport::TestCase
  test "deleting referral code doesn't delete referral" do
    referral = refer_referrals(:one)
    assert_not_nil referral.referral_code
    assert_no_difference "Refer::Referral.count" do
      referral.referral_code.destroy
    end
    referral.reload
    assert_nil referral.referral_code
  end

  test "referral codes are dependent destroyed" do
    assert_difference "Refer::ReferralCode.count", -1 do
      users(:one).destroy
    end
  end

  test "generates referral codes automatically" do
    original_generator = Refer.code_generator
    Refer.code_generator = ->(referrer) { SecureRandom.alphanumeric(8) }
    assert_not_nil users(:one).referral_codes.create!.code
  ensure
    Refer.code_generator = original_generator
  end

  test "does not generate referral code automatically if empty generator config" do
    original_generator = Refer.code_generator
    Refer.code_generator = nil
    assert_nil users(:one).referral_codes.create.code
  ensure
    Refer.code_generator = original_generator
  end

  test "does not generate referral code automatically if using a custom code" do
    Refer.code_generator = ->(referrer) { SecureRandom.alphanumeric(8) }
    custom_referral = users(:one).referral_codes.create(code: "custom")
    assert_equal custom_referral.code, "custom"
  end
end
