module ApplicationHelper

  def link_to_javascript(text, script, *args)
    link_to text, "#", :onclick => "#{script}; return false"
  end

  def header_tab(text, path)
    url = (path == root_url ? "/" : url_for(path))
    
    ("<li class='#{(url == request.fullpath) and 'active'}'>" + link_to(text, url) + "</li>").html_safe
  end

  def content_format(c)
    auto_link(c, :html => { :class => 'external' }) do |text|
       truncate(text.sub(/^http...www./,''), :length => 25)
     end    
  end
end
