# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  check_authorization unless: :devise_controller?

  default_form_builder AppFormBuilder

  before_action :set_default_request_format

  def set_default_request_format
    request.format = :html unless params[:format]
  end

  before_action :check_if_hs_open if Rails.env.production?
  before_action :check_for_present_people if Rails.env.production?
  before_action :check_for_hs_balance
  before_action :calc_kitty_number

  rescue_from CanCan::AccessDenied do |exception|
    message = "Cannot #{exception.action} on #{exception.subject}"
    Rails.logger.error message
    if current_user.nil?
      session[:next] = request.fullpath
      redirect_to new_user_session_url, alert: 'Вам необходимо войти в систему'
    else
      # render file: "#{Rails.root}/public/403.html", status: 403
      redirect_back(fallback_location: root_path, alert: 'У вас нет прав на выполнение этого действия')
    end
  end

  def check_if_hs_open
    @event = Event.light.where('created_at >= ?', 30.minutes.ago).order(created_at: :desc).first

    @hs_open_status = if @event.nil?
                        Hspace::UNKNOWN
                      else
                        event_status
                      end
    # @hs_open_status = Hspace::OPENED
    # для отладки индикатора
  end

  def check_for_present_people
    d = Device.find_by(name: 'bob')
    @hs_present_people = d.events.where('created_at >= ?', 5.minutes.ago).map(&:value)
    @hs_present_people.uniq!
  end

  def calc_kitty_number
    if user_signed_in? && !@hs_balance.nil?
      @hs_kitty_number = Rails.cache.fetch 'hs_kitty_number', expires_in: 3.hours do
        three_months_ago_date = Time.now - 3.months
        transactions = BankTransaction.where('created_at > ?', three_months_ago_date).where(irregular: false)
        the_sum = transactions.sum(:minus)
        (100 * @hs_balance / the_sum).round(1)
      end
    else
      @hs_kitty_number = 0
    end
  end

  def check_for_hs_balance
    return unless user_signed_in?

    # Fetches in app/services/fetch_bank_balance.rb
    @hs_balance = Rails.cache.read 'hs_balance'
  end

  private

  def event_status
    @event.value == 'on' ? Hspace::OPENED : Hspace::CLOSED
  end
end
