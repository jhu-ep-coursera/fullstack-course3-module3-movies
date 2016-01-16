class DirectorRef
  include Mongoid::Document
  field :name, type: String

  embedded_in :movie
  belongs_to :director, foreign_key: :_id
end
