class Movie
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title, type: String
  field :type, type: String
  field :rated, type: String
  field :year, type: Integer
  field :release_date, type: Date
  field :runtime, type: Measurement
  field :votes, type: Integer
  field :countries, type: Array
  field :languages, type: Array
  field :genres, type: Array
  field :filmingLocations, as: :filming_locations, type: Array
  field :metascore, type: String
  field :simplePlot, as: :simple_plot,  type: String
  field :plot, type: String
  field :urlIMDB, as: :url_imdb,  type: String
  field :urlPoster, as: :url_poster, type: String
  field :directors, type: Array
  field :actors, type: Array

  embeds_many :roles, class_name:"MovieRole"
  embeds_many :directors, class_name:"DirectorRef"
  has_and_belongs_to_many :writers
  has_one :sequel, foreign_key: :sequel_of, class_name:"Movie"
  belongs_to :sequel_to, foreign_key: :sequel_of, class_name:"Movie"

  before_destroy do |doc|
    puts "before_destroy Movie callback for #{doc.id}, "\
         "sequel_to=#{doc.sequel_to}, writers=#{doc.writer_ids}"
  end
  after_destroy do |doc|
    puts "after_destroy Movie callback for #{doc.id}, "\
         "sequel_to=#{doc.sequel_to}, writers=#{doc.writer_ids}"
  end

  scope :current, ->{ where(:year.gt=>Date.current.year-2) }

  def sanitize_for_mass_assignment(params)
    params ||= {}
    params.each_pair do |key, val|
      case 
      when ["runtime"].include?(key)
        params[key]=Measurement.demongoize(val)
      when ["countries",
            "languages",
            "genres",
            "filming_locations"].include?(key) && val.is_a?(String)
        params[key]=val.split(",").map {|v| v.strip }
      else
      end
    end
  end
end

