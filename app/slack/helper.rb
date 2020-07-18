# typed: false
# frozen_string_literal: true

module Slack
  module Helper
    def path_for(*args, **opts)
      arguments = args.map(&:to_s)
      match = SlackRouter.routes.map do |route, _controller|
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

      if !url_params.empty?
        stringified + '?' + URI.encode_www_form(url_params)
      else
        stringified
      end
    end
  end
end
