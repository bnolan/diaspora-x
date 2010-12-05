module ApplicationHelper

  def link_to_javascript(text, script, *args)
    link_to text, "#", :onclick => script
  end
  
end
