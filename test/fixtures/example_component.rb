class ExampleComponent < AmberComponents::BaseComponent
  def before_render
    @user = fetch_user_from_db
  end

  private

  # Example method
  def fetch_user_from_db
    {
      name: "#{@name}",
      email: "#{@name.gsub(' ', '').underscore}@example.com",
      age: 42,
      address: {
        street: '123 Main St',
        city: 'Anytown',
        state: 'California'
      }
    }
  end
end