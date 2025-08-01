# frozen_string_literal: true

# == Schema Information
#
# Table name: erip_transactions
#
#  id                     :integer          not null, primary key
#  status                 :string
#  message                :string
#  transaction_type       :string
#  transaction_id         :string
#  uid                    :string
#  order_id               :string
#  amount                 :decimal(, )
#  currency               :string
#  description            :string
#  tracking_id            :string
#  transaction_created_at :datetime
#  expired_at             :datetime
#  paid_at                :datetime
#  test                   :boolean
#  payment_method_type    :string
#  billing_address        :string
#  customer               :string
#  payment                :string
#  erip                   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  user_id                :integer
#
# Indexes
#
#  index_erip_transactions_on_transaction_id  (transaction_id) UNIQUE
#  index_erip_transactions_on_user_id         (user_id)
#

class EripTransaction < ApplicationRecord
  has_one :hs_payment, class_name: 'Payment'
  belongs_to :user, optional: true

  serialize :billing_address, coder: JSON
  serialize :customer, coder: JSON
  serialize :payment, coder: JSON
  serialize :erip, coder: JSON

  validates :transaction_id, uniqueness: true

  def to_human_s
    "...#{uid[-5..]}, status: #{status}, date: #{paid_at}, order: #{order_id}, amount: #{amount}"
  end
end
