module ApplicationHelper

  include EdgesoftNoCookie
  include Helpers::TranslateHelper
  include Helpers::FormattingHelper
  include Helpers::ChatHelper
  include Helpers::WizardsHelper
  include Helpers::TimerHelper
  include Helpers::AvatarUrlHelper
  include Helpers::DoubleRequestHelper
  include ActionView::Helpers::TextHelper

  def t(local_key, options = {})
    key = template.to_s.downcase.gsub(/\//, '.').gsub(/\.html\.erb$/, '')
    key = "views.#{key}.#{local_key}"
    translate key, options
  end

  # translation for views, will not use template name, just controller
  # can be used for global per controller messages
  def tv(local_key, options = {})
    key = template.to_s.downcase.gsub(/\//, '.').gsub(/\.[\w\_]*\.html\.erb$/, '')
    key = "views.#{key}.globals.#{local_key}"
    translate key, options
  end

  # translation for helpers
  def th(local_key, options = {})
    key = "views.helpers.#{local_key}"
    translate key, options
  end

  def game_url(name)
    GameProperties::GLOBAL_URLS[name]
  end

  def paginate(collection, params = {})
    params[:previous_label] = "Previous"
    params[:next_label] = "Next"

    will_paginate collection, params
  end

  def paginate_index(page, index)
    start_index = page.nil? ? 1 : Message.per_page * (page - 1) + 1
    start_index + index
  end

  def collect_content(&block)
    collected_content = capture(&block)
    collected_content = nil if collected_content.strip.empty?
    collected_content
  end

  def user_is_me?(user)
    user.id == current_user.id
  end

  def user_link(user, options = {})
    if user.monster? || user.dragon?
      user_name(user, options)
    else
      link_text = user_name(user, options)
      link_text += options[:additional] if !options[:additional].nil?
      link_to_ajax link_text, {:url => profile_path(:id => user.id)}, options
    end
  end

  def image_design_tag(source, options = {})
    image_tag("/images/design/#{source}", options)
  end

  def remote_url(options)
    url = ''
    url_options = options[:url]
    url_options = url_options.merge(:escape => false) if url_options.is_a?(Hash)
    begin
      url = escape_javascript(url_for(url_options))
    rescue
    end
    url
  end

  #deprecated use link_to_ajax in controller render_popup
  def link_to_ajax_content(name, options = {}, html_options = {})
    options[:update] ||= "dialog_content"

    options[:loading] ||= ""
    options[:loading] << "javascript: onLoading('#{remote_url(options)}');"

    options[:loaded] = "javascript: onLoaded('#{remote_url(options)}')"

    html_options[:href] = "javascript: void(0)"
    link_to_remote name, options, html_options
  end

  def link_to_ajax(name, options = {}, html_options = {})
    if options.is_a? String
      options = { :url => options }
    end

    if GameProperties.is_enabled_mode?(:ajax) || options[:url].include?("force_ajax")

      options[:loading] ||= ""
      options[:loading] << "javascript: onLoading('#{remote_url(options)}');"
      options[:loaded]  = "javascript: onLoaded('#{remote_url(options)}');"
      options[:url]     = "javascript: void(0)" if options[:url].blank?
      
      html_options[:href] = hi5_host? ? "http://www.hi5.com/friend/apps/entry/7wizards/" : "#{remote_url(options)}"

      link_to_remote name, options, html_options
    else
      link_to name, options[:url], html_options
    end
  end

  def form_ajax_tag(options, &block)

    if GameProperties.is_enabled_mode?(:ajax) || options[:url].include?("force_ajax")
      options[:loading] ||= "onLoading('#{remote_url(options)}');"
      options[:loaded] ||= "onLoaded('#{remote_url(options)}')"
      form_remote_tag(options, &block)
    else
      form_tag(options[:url], &block)
    end
  end

  def form_ajax_for(record_or_name_or_array, *args, &proc)

    if GameProperties.is_enabled_mode?(:ajax)
      args.first[:loading] ||= "onLoading('#{remote_url(args.first)}')"
      args.first[:loaded] ||= "onLoaded('#{remote_url(args.first)}');"
      form_remote_for(record_or_name_or_array, *args, &proc)
    else
      form_for(record_or_name_or_array, *args, &proc)
    end
  end

  def remote_form_check(obj_name, attrib_name)
    remote_function(:url => {:action => 'check_form'},
      :with => "'#{obj_name}[#{attrib_name}]='+this.value")
  end

  def user_item_image_url(item)
    item = item.class unless item.is_a?(Class)
    item.image_url
  end

  def user_item_image_tag(item)
    image_tag user_item_image_url(item), {:title => item.title, :alt => item.title, :width => 102, :height => 102}
  end

  def user_attribute_image_tag(name)
    name = name.to_s
    name = "a_#{name}" if !name.starts_with?("a_")
    title = tf User, name
    image_tag "/images/user/#{name}.png",
      {:alt => title, :width => 102, :height => 102}
  end

  def game_item_image_tag(item)
    image_tag "/images/user/g_#{item.key}.png",
      {:alt => item.title, :width => 102, :height => 102}
  end

  def clan_item_image_tag(item)
    image_tag "/images/clan/#{item.key}.jpg",
      {:alt => item.title, :width => 102, :height => 102}
  end

  def navigation_links(&block)
    concat("<ul class='navigate'>#{capture(&block)}</ul>")
  end

  def navigation_link(*args, &block)
    "<li>#{link_to_ajax(*args, &block)}</li>"
  end

  #javascript function, for ajax history
  def add_simple_history(url)
    page << %[addHistory("#{url}")]
  end

  def add_events(options = {})
    page << %[addEvents(#{options.to_json})]
  end

  def value_or_blank(user, attribute)
    return "" if user.nil? || user[attribute.to_s].nil?
    user[attribute.to_s]
  end

  def confirm_link(name, confirmation, options, html_options = {})
    confirm_url = options[:url]
    confirmation = name.downcase unless confirmation
    options[:url] = wizards_path(:action => :confirm_dialog, :confirmation => CGI::escape(confirmation), :confirm_url => CGI::escape(confirm_url))
    link_to_ajax(name, options, html_options)
  end

  def link_flash_avatar(ava)
    link_to image_tag("skins/#{ava.key}.gif"), "javascript:void(0)", :onclick => "javascript: load_avatar('flash_content', '#{ava.key}')"
  end

  def user_name(user, options = {})
    name = 'Unknown'
    if user.is_a?(User) || user.is_a?(UserExt::UserAttributes)
      name = user.confirmed_email ? user.name : "Activateme #{user.user_id}"
    elsif user.respond_to?(:name)
      name = user.send(:name)
    end
    name = truncate(name, :length => 14) if options[:short_name]
    name
  end

  def user_image(user, big = false, options = {})
    options[:class] = "avatar_img avatar_smal_list"
    options[:onerror] = "this.src = '#{UserAvatarService.get_default_image_url(user)}'"
    options[:link] ? link_to_ajax(image_tag(user_image_url(user, big), options), {:url => profile_path(:id => user.id)}) : image_tag(user_image_url(user, big), options)
    
  end

  def clan_image(clan, front_options = {}, back_options = {})
    front_options[:class]  ||= "front_logo"
    front_options[:height] ||= 200
    front_options[:width]  ||= 200

    back_options[:height]  ||= back_options[:height]
    back_options[:width]   ||= back_options[:width]

    logo_block = <<-LOGO
      <div class="logo_block_200" style="height: #{front_options[:height]}px; width: #{front_options[:width]}px">
        #{image_tag clan_image_url(clan, true), back_options}
        #{image_tag clan_image_url(clan, false), front_options}
      </div>
    LOGO
    front_options[:link] ? link_to_ajax(logo_block, :url => clan_path(:action => :details, :id => clan.id)) : logo_block
  end

  def dragon_image(dragon)
    user_image dragon
  end

  def pet_image(user_or_kind, big = false, suffix = '')
    path = pet_image_url(user_or_kind, big, suffix)
    if path
      image_tag path, :height => 263, :width => 254
    else
      ""
    end
  end

  def pet_name(kind)
    tf(User, "pet#{kind}_name")
  end

  def clan_name(user_or_clan, options = {})
    if !user_or_clan.clan_name.blank?
      r = options[:long] ? "#{tf(User, :clan)} : " : ''
      r += h(user_or_clan.clan_name)

      c = current_user.clan
    end
    r += clan_info(user_or_clan) if c
    r
  end

  def clan_link(user_or_clan, options = {})
    if !user_or_clan.clan_name.blank?
      r = options[:long] ? "#{tf(User, :clan)} : " : ''
      r += link_to_ajax(user_or_clan.clan_name, :url => clan_path(:action => :details, :id => user_or_clan.clan_id))
    end
    r
  end

  def clan_info(user_or_clan)
    r = ""
    return r if user_or_clan.clan_name.blank?

    c = current_user.clan
    if c
      if c.id == user_or_clan.clan_id
        r = tf(User, :your_clan_mark)
      else
        if c.has_union? user_or_clan.clan_id
          r = tf(User, :union_clan_mark)
        end
      end
    end
    r
  end

  def is_online_image_tag(user, options = {})
    return "" if user.nil?
    options.merge!({:size => "9x9"})
    if user.is_online?
      options[:title] = tf(User, :online)
      image_design_tag("online_chat_pointer.png", options)
    else
      options[:title] = tf(User, :offline)
      image_design_tag("offline_chat_pointer.png", options)
    end
  end

  def is_online_by_time_image_tag(time)
    (!time.nil? && time > GameProperties::USER_ACTIVE_PERIOD.ago) ?
      image_design_tag("online_chat_pointer.png", :size => "9x9") :
      image_design_tag("offline_chat_pointer.png", :size => "9x9")
  end

  #truncate by words
  def truncate_words(text, *args)
    text = truncate(text, *args)
    text[0..text.rindex(' ')] + args[0][:omission]
  end

  def select_custom_tag(name, options_tag = nil, options = {})
    options[:class] = "styled"
    tag = "<span style='position:relative; display: inline-block'><span class='select'>select</span>"
    tag << select_tag(name, options_tag, options)
    tag << "</span>"
    tag
  end

  def text_field_custom_tag(name, value, options = {}, url = "javascript: void(0)")
    options[:class] ||= ""
    options[:class] << " styled"
    tag = "<span class='input'>"
    tag << text_field_tag(name, value, options)
    tag << link_to_ajax(image_design_tag("filter_clear.jpg", :class=>"clear"), {:url => url}, {:class => "styled_close", :style => "display:none", :title => "Clear"})
    tag << "</span>"
    tag
  end

  def price_tag(options = {})
    if options[:price]
      img = "#{options[:price]} <span style='width: 30px;text-align:center; display: inline-block'>#{image_design_tag("menu_mana.png", :width => 14, :height => 21)}</span>"
    elsif options[:price_staff]
      img = "#{options[:price_staff]} <span>#{image_design_tag("menu_money.png", :width => 27, :height => 21)}</span>"
    end
    "<span style='white-space: nowrap'><b>#{img}</b></span>"
  end

  #usage for blank gifts and curses
  def blank_count(items, per_line)
    count = per_line - (items.size % per_line)
    if per_line == count && items.size > 0
      count = 0
    end
    count
  end

  def link_to_top(title)
    return hi5_host? ? "" : link_to(title, "javascript: wizards.onScrollTop()", :class => "more") 
  end

end