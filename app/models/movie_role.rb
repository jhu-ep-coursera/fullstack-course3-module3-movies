class MovieRole
  include Mongoid::Document
  field :character, type: String
  field :actorName, as: :actor_name, type: String
  field :main, type: Mongoid::Boolean
  field :urlCharacter, as: :url_character, type: String
  field :urlPhoto, as: :url_photo, type: String
  field :urlProfile, as: :url_profile, type: String

  embedded_in :movie
  belongs_to :actor, foreign_key: :_id, touch: true 
end
