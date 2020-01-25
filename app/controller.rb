require_relative 'garage'
require_relative 'store'
require_relative 'http_client'

module Controller
  def self.call(request_data)
    # /garage command received
    if request_data['token']
      command_text = request_data['text'][0]
      building     = (command_text && command_text[0].downcase == 's') ? Store::SALDOVKA : Store::RIVER
      Garage.park(request_data['user_id'], building)

    # button interaction received
    else
      parsed   = JSON.parse request_data['payload']
      puts parsed
      building = parsed['actions'][0]['block_id'].split('-')[0]
      action   = parsed['actions'][0]['text']['text'].downcase == 'book' ? :book : :cancel
      date     = DateTime.parse(parsed['actions'][0]['value']).to_time
      user     = parsed['user']['id']
      _persist = Store.call(action, date, user, building)

      response_msg = Garage.park(user, building)

      HTTPClient.post(parsed['response_url'], response_msg)
    end
  end
end
