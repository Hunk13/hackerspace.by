# == Schema Information
#
# Table name: users
#
#  id                       :integer          not null, primary key
#  email                    :string           default(""), not null
#  encrypted_password       :string           default(""), not null
#  reset_password_token     :string
#  reset_password_sent_at   :datetime
#  remember_created_at      :datetime
#  sign_in_count            :integer          default(0), not null
#  current_sign_in_at       :datetime
#  last_sign_in_at          :datetime
#  current_sign_in_ip       :string
#  last_sign_in_ip          :string
#  created_at               :datetime
#  updated_at               :datetime
#  hacker_comment           :string
#  photo_file_name          :string
#  photo_content_type       :string
#  photo_file_size          :integer
#  photo_updated_at         :datetime
#  first_name               :string
#  last_name                :string
#  bepaid_number            :integer
#  telegram_username        :string
#  alice_greeting           :string
#  last_seen_in_hackerspace :datetime
#  account_suspended        :boolean
#  account_banned           :boolean
#  github_username          :string
#  is_learner               :boolean          default(FALSE)
#  project_id               :integer
#  guarantor1_id            :integer
#  guarantor2_id            :integer
#  suspended_changed_at     :datetime         default(Fri, 31 Dec 2010 20:21:50.000000000 EET +02:00), not null
#  tariff_id                :integer
#  tg_auth_token            :string
#  tg_auth_token_expiry     :datetime
#  tariff_changed_at        :datetime
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_guarantor1_id         (guarantor1_id)
#  index_users_on_guarantor2_id         (guarantor2_id)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_tariff_id             (tariff_id)
#
# Foreign Keys
#
#  tariff_id  (tariff_id => tariffs.id)
#

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
