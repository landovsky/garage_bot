# typed: true
# frozen_string_literal: true

require_relative 'application_controller'
require_relative 'http_client'
require_relative 'utils'
require 'cgi'

module SlackApp
  class Router
    SLACK = HTTPClient
    U     = Utils

    def self.routes
      command = ENV['BOT_ENV'] == 'dev' || ENV['BOT_ENV'] == 'test' || ENV['BOT_ENV'] == 'aws-dev' ? :tmp : :garage
      {
        'garage' => 'garage#park',
        'garage/:date/spot/:spot_id/book' => 'garage#book_spot',
        'garage/:date/spot/:spot_id/cancel' => 'garage#cancel_spot',
        'garage/parkers' => 'garage#who_parked',
        'slack_event/app_home_opened' => 'garage#park',
        "command/#{command}" => 'garage#test',
        "form_test" => 'garage#form_modal'
      }
    end

    def self.respond_to_challenge?(payload)
      payload[:challenge]
    end

    def self.parse_payload(raw_payload)
      return raw_payload.symbolize_keys if raw_payload.is_a? Hash

      parsed = if raw_payload.start_with? 'payload'
                JSON.parse(URI.decode_www_form(raw_payload)[0][1])
              elsif raw_payload.start_with? 'token'
                URI.decode_www_form(raw_payload).to_h
              else
                JSON.parse(raw_payload)
              end
      parsed.symbolize_keys
    end

    def self.call(raw_payload)
      payload = parse_payload(raw_payload)
      File.open('tmp/payload-incoming.json', 'wb') { |file| file.write JSON.dump(payload) } if ENV['BOT_ENV'] == 'dev'

      return payload[:challenge] if respond_to_challenge?(payload)

      response_handler = build_response_handler(payload)

      if response_handler[:type] == :event
        controller, _route = find_event_route(payload)
        params             = { user_id: payload.dig(:event, :user) }
      elsif response_handler[:type] == :command
        controller, _route = find_command_route(payload)
        params             = { user_id: payload[:user_id] }
      elsif response_handler[:type] == :message
        controller, _route, route_params = find_route(payload)
        data, params    = parse_params(payload)
        params          = data ? route_params.merge(data).merge(params: params) : {}
      elsif response_handler[:type] == :view_submission
        puts payload
      else
        controller, _route, route_params = find_route(payload)
        data, params    = parse_params(payload)
        params          = data ? route_params.merge(data).merge(params: params) : {}
      end

      ApplicationController.call(controller, params, response_handler)
    rescue => e
      U.error e
      raise e
    end

    def self.build_response_handler(payload)
      test_env = ENV['BOT_ENV'] == 'test'
      dev_env  = ENV['BOT_ENV'] == 'dev'

      if payload[:event]
        user_id = payload[:event][:user]

        wrapper = proc { |content| { user_id: user_id, view: SlackApp::DSL.home_view(content) } }
        meth = proc do |content|
          response = wrapper[content]
          U.log_output(response) if dev_env
          test_env ? response : SLACK.views_publish(response)
        end
        { type: :event, method: meth }

      elsif payload[:view]
        user_id = payload[:user][:id]
        view_id = payload[:view][:id]

        wrapper = proc { |content|
          {
            view_id: view_id,
            user_id: user_id,
            view: (modal_requested?(payload) ? content : SlackApp::DSL.home_view(content))
          }
        }
        meth = proc do |content|
          response = wrapper[content]
          U.log_output(response) if dev_env
          test_env ? response : SLACK.views_update(response)
        end
        { type: :view, method: meth }

      elsif payload[:command]
        meth = proc do |content|
          response = SlackApp::DSL.blocks_wrapper(content)
          U.log_output response if dev_env
          response
        end
        { type: :command, method: meth }

      elsif payload.dig(:container, :type) == 'message' && payload[:response_url]
        url = payload[:response_url]

        wrapper = if modal_requested?(payload)
          proc { |content| { trigger_id: payload[:trigger_id], view: content } }
        else
          proc { |content| SlackApp::DSL.blocks_wrapper(content) }
        end

        meth = proc do |content|
          response = wrapper[content]
          U.log_output(response) if dev_env
          test_env ? response : (modal_requested?(payload) ? SLACK.views_open(response) : SLACK.post(url, response))
        end
        { type: :message, method: meth }
      else
        raise 'unhandled payload type'
      end
    end

    def self.modal_requested?(payload)
      parse_params(payload)[1][:modal] == "true"
    end

    def self.find_event_route(payload)
      action = 'slack_event/' + payload[:event][:type]

      controller = routes[action]
      raise "no route found for #{action}" unless controller

      [controller, action]
    end

    def self.find_command_route(payload)
      action = 'command' + payload[:command]

      controller = routes[action]
      raise "no route found for #{action}" if controller&.empty?

      [controller, action]
    end

    def self.parse_params(payload)
      return if payload[:actions].empty?

      # TODO could there be more actions?
      action = payload[:actions][0][:action_id]
      params = action.split('?')[1] || ''

      data = {
        user_id: payload.dig(:user, :id)
      }
      params = CGI.parse(params).map do |k, v|
        [k, v.count == 1 ? v[0] : v]
      end.to_h.symbolize_keys

      [data, params]
    end

    def self.find_route(payload)
      # TODO what if there are more actions?
      action = payload[:actions][0][:action_id]
      puts "actions: #{action}"
      action_items = action.split('?')[0].split('/')

      routes_without_events = routes.reject { |r| r.start_with? 'slack_event' }

      selected_route = nil

      routes_without_events.each_entry do |route, controller|
        route_items = route.split('/')
        next if action_items.count != route_items.count

        params = []

        match = route_items.all? do |item|
          item_index = route_items.index(item)

          if item.start_with? ':'
            params << [item.sub(':', '').to_sym, action_items[item_index]]
            next true
          end
          action_items[item_index] == item
        end

        selected_route = [controller, route, params.to_h] if match
      end
      raise "no route found for #{action}" unless selected_route

      selected_route
    rescue => e
      U.error e
    end
  end
end