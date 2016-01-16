class Place
  include Mongoid::Document
  field :_id, type: String, default: -> { formatted_address }
  field :formatted_address, type: String
  field :geolocation, type: Point
  field :street_number, type: String
  field :street_name, type: String
  field :city, type: String
  field :postal_code, type: String
  field :county, type: String
  field :state, type: String
  field :country, type: String

  embedded_in :locatable, polymorphic: true 

  def sanitize_for_mass_assignment(params)
    params ||= {}
    params.each_pair do |key, val|
      case 
      when ["geolocation"].include?(key)
        params[key]=Point.demongoize(val)
      else
      end
    end
  end
end
