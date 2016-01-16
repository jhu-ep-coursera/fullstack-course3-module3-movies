class Actor
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :birthName, as: :birth_name, type: String
  field :date_of_birth, type: Date
  field :height, type: Measurement
  field :bio, type: String

  embeds_one :place_of_birth, class_name: 'Place' , as: :locatable

  index ({ :"place_of_birth.geolocation" => Mongo::Index::GEO2DSPHERE })

  #sort-of has_many :movies, class_name:"Movie"
  def movies
    Movie.where(:"roles._id"=>self.id)
  end
  #sort-of has_many roles:, class_name: 'MovieRole`
  def roles
    Movie.where(:"roles._id"=>self.id).map {|m| m.roles.where(:_id=>self.id).first}
  end  

  def self.near_pob place, max_meters
    near(:"place_of_birth.geolocation" => place.geolocation)
    .max_distance(:"place_of_birth.geolocation" =>max_meters)
  end

  def sanitize_for_mass_assignment(params)
    params ||= {}
    params.each_pair do |key, val|
      case 
      when ["height"].include?(key)
        params[key]=Measurement.demongoize(val)
      else
      end
    end
  end
end
