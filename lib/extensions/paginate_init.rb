module Paginate
  class LinkRenderer < WillPaginate::LinkRenderer
    def page_link(page, text, attributes = {})
      @options[:params] && @options[:params][:simple_link] ? @template.link_to(text, url_for(page), attributes) : @template.link_to_ajax(text, url_for(page), attributes)
    end
  end
end

WillPaginate::ViewHelpers.pagination_options[:renderer] = 'Paginate::LinkRenderer'