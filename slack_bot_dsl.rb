Routes.draw do
  post 'garage:words' => 'garage#park'
  post 'interaction:book' => 'garage#book'
  post 'interaction:cancel' => 'garage#cancel'
end

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
        button 'Cancel', action: :cancel, value: :cancel, type: :text
      end
    end
    divider
    section
  end

  def helper_method
  end
end
