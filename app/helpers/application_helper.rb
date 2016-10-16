module ApplicationHelper

  # Returns the full title on a per-page basis.
  def full_title(page_title = '')
    base_title = "Ruby on Rails Tutorial Sample App"
    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
    end
  end
end

=begin
The full_title helper returns a base title, “Ruby on Rails Tutorial Sample App”, if no page title is defined,
and adds a vertical bar preceded by the page title if one is defined
=end
