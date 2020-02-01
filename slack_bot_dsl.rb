# parse(payload)
# => identify controller#method (from routes)
# => collect data from interactions / forms
# => identify method for response
# => call controller

# controller(response_method, params)
# => use params
# => controller / model custom code
# => creating response from view
# => internally: respond, using correct response method

routes = {
  'garage' => 'garage#park',
  'garage/:date/book' => 'garage#book',
  'garage/:date/cancel' => 'garage#cancel',
  'slack_event:app_home_opened' => 'garage#park'
}

# garage/:day/cancel
# garage/:day/book
# garage

# Sources
# => event
# => reaction from view
# => reaction from message

class GarageController
  def garage
    load_some_data
    render 'garage_view'
  end
end

class Interaction
  def book
  end
end

# section
# button
# accessory
# text

class GarageView
  def render
    section 'block_id' do
      text 'some text', type: :markdown
      accessory do
        # garage/2020-01-31/cancel
        button 'Cancel', Garage.link_to(date, :cancel), value: :cancel, type: :text
      end
    end
    divider
    section
  end

  def helper_method
  end
end
