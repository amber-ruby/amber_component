class MethodAndFileViewComponent < AmberComponent::Base
  view <<~ERB.chomp
    Hello <%= @name %>!
  ERB
end
