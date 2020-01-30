# frozen_string_literal: true

require_relative 'application_controller'

class SlackRouter
  def self.routes
    {
      'garage' => 'garage#park',
      'garage/:date/book' => 'garage#book',
      'garage/:date/cancel' => 'garage#cancel',
      'slack_event:app_home_opened' => 'garage#park'
    }
  end

  def self.action(*args, **opts)
    arguments = args.map(&:to_s)
    match = routes.map do |route, _controller|
      next if route.start_with? 'slack_event'

      route_items = route.split('/')
      route_items_without_params = route_items.reject { |i| i.start_with? ':' }

      next if route_items_without_params.sort != arguments.sort

      route
    end.compact.first
    raise "no action found for '#{arguments.join(' - ')}' keywords" if match.nil?

    url_params = opts
    action = match.split('/').each_with_object([]) do |item, o|
      if item.start_with? ':'
        param = item.gsub(':', '').to_sym
        param_value = opts[param]
        raise "param '#{param}' in route #{match} not found in options" unless param_value

        url_params = url_params.except param
        o << param_value
      else
        matched_index = arguments.index(item)
        raise "action '#{item}' not found in arguments" unless matched_index

        o << arguments.delete_at(matched_index)
      end
    end

    stringified = action.join('/')

    if url_params.present?
      stringified + '?' + URI.encode_www_form(url_params)
    else
      stringified
    end
  end

  def self.hash_select(hash, keys)
    Hash[*hash.select { |k, v| keys.include?(k) }.flatten]
  end

  def self.call(payload)
    controller, route_params, _route = find_route(payload)
    data, params    = parse_params(payload)
    params          = route_params.merge(data).merge(params: params)
    response_method = identify_resonse_method(payload)

    ApplicationController.call(controller, params, response_method)
  end

  def self.identify_resonse_method(payload)
    user_id = payload['user']['id']

    proc { |content| SLACK.views_publish(user_id: user_id, view: Slack::DSL.view(:home, content)) }
  end

  def self.parse_params(payload)
    action = payload['actions'][0]['action_id']
    params = action.split('?')[1] || ''

    data = {
      user: payload.dig('user', 'id')
    }
    params = CGI.parse(params).map do |k, v|
      [k, v.count == 1 ? v[0] : v]
    end.to_h.with_indifferent_access

    [data, params]
  end

  def self.find_route(payload)
    action = payload['actions'][0]['action_id']
    action_items = action.split('?')[0].split('/')

    selected_route = routes.map do |route, controller|
      next [] if route.start_with? 'slack_event'

      route_items = route.split('/')
      # puts "#{action} #{action_items.count} #{route_items.count}"
      next [] if action_items.count != route_items.count

      params = []

      match = route_items.all? do |item|
        item_index = route_items.index(item)
        if item.start_with? ':'
          params << [item.sub(':', '').to_sym, action_items[item_index]]
          next true
        end
        action_items[item_index] == item
      end

      return [controller, params.to_h, route] if match

      raise "no route found for #{action}"
    end.first
    raise "no route found for #{action}" if selected_route.empty?

    selected_route
  rescue => e
    # Logger.submit 'could not find any matching routes', action: action
    puts e
    puts e.backtrace[0]
  end
end
