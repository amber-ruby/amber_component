# frozen_string_literal: true

require 'ostruct'

class MarkdownComponent < AmberComponent::Base
  before_render do
    fetch_user_data
  end

  private

  def fetch_user_data
    @user = OpenStruct.new(
      name: 'John Doe',
      email: 'john_doe@example.com',
      last_login: "2022-07-25 11:01:41",
      balance: 200
    )
  end
end
