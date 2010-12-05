module ApplicationHelper

  def link_to_javascript(text, script, *args)
    link_to text, "#", :onclick => script
  end

  def header_tab(text, path)
    url = (path == root_url ? "/" : url_for(path))
    
    ("<li class='#{(url == request.request_uri) and 'active'}'>" + link_to(text, url) + "</li>").html_safe
  end
  
end
