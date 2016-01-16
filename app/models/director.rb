class Director
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String

  belongs_to :residence, class_name: 'Place'
  def movies
    Movie.where(:"directors._id"=>self.id)
  end

  validates_presence_of :name
end
