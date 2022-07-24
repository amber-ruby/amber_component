# frozen_string_literal: true

require 'ostruct'

class ::ExampleComponent < ::AmberComponents::BaseComponent
  before_render do
    @user = fetch_user_from_db
  end

  private

  # Example method
  def fetch_user_from_db
    ::OpenStruct.new({
      name: "#{@name}",
      email: "#{@name.gsub(' ', '').underscore}@example.com",
    })
  end
end
