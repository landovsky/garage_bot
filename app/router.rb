# parse(payload)
# => ok: identify controller#method (from routes)
# => ok: collect data from interactions / forms
# => ok: parse params
# => identify method for response
# => call controller

class Router
  def self.routes
    {
      'garage' => 'garage#park',
      'garage/:date/book' => 'garage#book',
      'garage/:date/cancel' => 'garage#cancel',
      'slack_event:app_home_opened' => 'garage#park'
    }
  end

  def self.parse_data(payload)
    action = payload['actions']['action_id']
    params = action.split('?')[1] || ''

    {
      user: payload.dig('user', 'id'),
      params: CGI.parse(params).with_indifferent_access
    }
  end

  def self.find_route(payload)
    action = payload['actions']['action_id']
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

      return [route, controller, params.to_h] if match

      return "no route found for #{action}"
    end.first
    raise "no route found for #{action}" if selected_route.empty?

    selected_route
  rescue => e
    # Logger.submit 'could not find any matching routes', action: action
    puts e
    puts e.backtrace[0]
  end
end
