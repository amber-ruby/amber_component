# frozen_string_literal: true

require 'ostruct'

class StyledComponent < AmberComponent::Base
  before_render do
    fetch_user_data
  end

  private

  def fetch_user_data
    @user = OpenStruct.new(
      name: 'John Doe',
      email: 'john_doe@example.com',
      last_login: Time.new.utc.to_s,
      balance: rand(1000)
    )
  end
end
