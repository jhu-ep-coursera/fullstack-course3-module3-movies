class Writer
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String

  embeds_one :hometown, as: :locatable, class_name: 'Place'
  has_and_belongs_to_many :movies

  before_destroy do |doc|
    puts "before_destroy Writer callback for #{doc.id}, "\
        "movies=#{doc.movie_ids}"
  end
  after_destroy do |doc|
    puts "after_destroy Writer callback for #{doc.id}, "\
        "movies=#{doc.movie_ids}"
  end
end
