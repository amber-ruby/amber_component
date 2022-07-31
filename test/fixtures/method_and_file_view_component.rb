class MethodAndFileViewComponent < AmberComponent::Base
  view do
    <<~ERB.chomp
      Hello <%= @name %>!
    ERB
  end
end
