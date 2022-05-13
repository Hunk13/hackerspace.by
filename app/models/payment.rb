# == Schema Information
#
# Table name: payments
#
#  id                  :integer          not null, primary key
#  user_id             :integer
#  erip_transaction_id :integer
#  paid_at             :datetime         not null
#  amount              :decimal(, )      default(0.0), not null
#  start_date          :date
#  end_date            :date
#  payment_type        :string           not null
#  payment_form        :string           not null
#  description         :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  project_id          :integer
#
# Indexes
#
#  index_payments_on_erip_transaction_id  (erip_transaction_id)
#  index_payments_on_project_id           (project_id)
#  index_payments_on_user_id              (user_id)
#

class Payment < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :erip_transaction, optional: true
  belongs_to :project, optional: true

  validates :paid_at, presence: true
  validates :amount, presence: true
  validates :erip_transaction_id, presence: true, if: Proc.new {|p| p.payment_type == 'erip'}
  validates :payment_type, :inclusion => { in: %w(membership donation) }
  validates :payment_form, :inclusion => { in: %w(erip cash natural) }
  validate :start_date_before_of_end_date
  validates :start_date, presence: true, if: Proc.new {|p| p.payment_type == 'membership'}
  validates :end_date, presence: true, if: Proc.new {|p| p.payment_type == 'membership'}
  validates :description, presence: true, if: Proc.new {|p| p.payment_form == 'natural'}

  after_save :set_user_as_unsuspended

  def self.user_ids
    distinct.pluck(:user_id).compact
  end

  private

  # end_date – last day of paid period. If payment amount is less
  # than (monthly amount / 30), end_date will be one day before the last day.
  #
  def start_date_before_of_end_date
    return if self.start_date.nil? or self.end_date.nil?
    if self.start_date - 1 > self.end_date
      errors.add(:end_date, "should be after or equal to start date")
    end
  end

  def set_user_as_unsuspended
    if user.present?
      return unless user.account_suspended?
      return if user.account_banned?

      if user.last_payment && (user.last_payment.end_date - user.first_payment_after_last_suspend.start_date + 1.day >= 14.days)
        user.unsuspend!
      end
    end
  end
end
