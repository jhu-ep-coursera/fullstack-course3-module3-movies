
namespace :movies do
  desc "performs seed from raw files"
  task raw_seed: :environment do
    Actor.collection.find.delete_many
    Movie.collection.find.delete_many
    Director.collection.find.delete_many
    Writer.collection.find.delete_many
    Place.collection.find.delete_many
    Actor.create_indexes
    Place.create_indexes

    #ingest the original documents
    JSON.parse(File.read('db/actors-raw.json')).each do |doc|
      #assign the internal/unique imdb key as the _id primary key
      doc[:_id]=doc["idIMDB"]
      doc.delete "idIMDB" 

      #clean up birth date
      string_date=doc["dateOfBirth"]
      if string_date
        case
        when /^\d{4}$/ =~ string_date then dob=Date.strptime(string_date, "%Y")
        when /^\d{1,2} \w+ \d{4}$/ =~ string_date then dob=Date.strptime(string_date, "%d %B %Y")
        when /^\w+\d{4}$/ =~ string_date then dob=Date.strptime(string_date, "%B%Y")
        else raise "invalid date #{string_date} for #{doc[:name]}"
        end
        doc[:date_of_birth]=dob
        doc.delete "dateOfBirth"
      end

      #convet height to a measurement
      height=doc["height"]
      if height && (meters=height.scrub![/\(([0-9.]+) m\)/,1])
        doc["height"]=Measurement.new(meters.to_f * 3.28084, "feet").mongoize
      end

      Actor.collection.find_one_and_replace({:_id=>doc[:_id]}, doc, {:upsert=>true})
    end

    JSON.parse(File.read('db/movies-raw.json')).each do |doc|
      #assign the internal/unique imdb key as the _id primary key
      doc[:_id]=doc["idIMDB"]
      doc.delete "idIMDB" 


      if doc["actors"]
        #change movie.actors to movie.roles
        doc[:roles]=doc["actors"]
        doc.delete "actors"

        #change key to actors within roles to use _id
        doc[:roles].each do |role|
          role[:_id]=role["actorId"]
          role.delete "actorId"
        end
      end

      if doc["directors"]
        #change key to directors to use _id
        doc["directors"].each do |dir|
          dir[:_id]=dir["nameId"]
          dir.delete "nameId"
          r=Director.collection.find_one_and_replace({:_id=>dir[:_id]},dir,{:upsert=>true})
        end
      end

      if doc["writers"]
        #change writers to a pure many-to-many
        writers=[]
        doc["writers"].each do |w|
          Writer.new(:_id=>w["nameId"], :name=>w["name"]).upsert
          writers << w["nameId"]
        end
        doc[:writer_ids]=writers
        doc.delete "writers"
      end

      if doc["rating"]
        #make the rating a number value
        doc["rating"]=doc["rating"].to_f
      end

      if doc["year"]
        #make the year a number value
        doc["year"]=doc["year"].to_i
      end

      if doc["votes"]
        #make the votes a number value
        doc["votes"]=doc["votes"].tr(",","").to_i
      end

      runtime=doc["runtime"]
      if runtime && runtime=runtime[0]
        #make the runtime a number value
        case
        when /^(\d+) min$/ =~ runtime then 
          min=runtime.scan(/^(\d+) min$/).first.last
          runtime=Measurement.new(min.to_i, "min").mongoize
        else raise "invalid runtime duration #{runtime}"
        end
        doc["runtime"]=runtime
      end

      string_date=doc["releaseDate"]
      if string_date
        #make the releaseDate a real date
        case
        when /^\d{8}$/ =~ string_date then dob=Date.strptime(string_date, "%Y%M%d")
        when /^\d{4}$/ =~ string_date then dob=Date.strptime(string_date, "%Y")
        when /^\d{1,2} \w+ \d{4}$/ =~ string_date then dob=Date.strptime(string_date, "%d %B %Y")
        when /^\w+\d{4}$/ =~ string_date then dob=Date.strptime(string_date, "%B%Y")
        else raise "invalid date #{string_date} for #{doc[:name]}"
        end
        doc[:release_date]=dob
        doc.delete "releaseDate"
      end

      Movie.collection.find_one_and_replace({:_id=>doc[:_id]}, doc, {:upsert=>true})
    end

    #update links on Writer-side
    Writer.each do |writer|
      Movie.where(:writer_ids=>writer.id).each do |movie|
        writer.movies << movie
      end
      writer.save
    end

    Actor.collection.find(:placeOfBirth=>{:$exists=>true}).each do |doc|
      placeOfBirth=doc[:placeOfBirth].strip
      places=[]
      #HTTParty is returning string keys in hash
      places=HTTParty.get("https://maps.googleapis.com/maps/api/geocode/json",
                          query:{address: placeOfBirth, key:ENV['GMAPS_KEY']})["results"]

      pob=nil
      if places[0]
        place=places[0]
        place.deep_symbolize_keys!    #httparty returns string keys
        geolocation=Point.mongoize(place[:geometry][:location])
        address_components=place[:address_components]
        country=address_components.select {|r| r[:types].include? "country"}.map {|r| r[:short_name] }[0]
        postal=address_components.select {|r| r[:types].include? "postal_code"}.map {|r| r[:short_name] }[0]
        county=address_components.select {|r| r[:types].include? "administrative_area_level_2"}.map {|r| r[:short_name] }[0]
        state=address_components.select {|r| r[:types].include? "administrative_area_level_1"}.map {|r| r[:short_name] }[0]
        streetno=address_components.select {|r| r[:types].include? "street_number"}.map {|r| r[:short_name] }[0]
        street=address_components.select {|r| r[:types].include? "route"}.map {|r| r[:short_name] }[0]
        city=address_components.select {|r| r[:types].include? "locality"}.map {|r| r[:short_name] }[0]

        pob={:_id=>place[:formatted_address], :geolocation=>geolocation}
        pob[:street_number]=streetno   if streetno
        pob[:street_name]=street       if street
        pob[:city]=city                if city
        pob[:postal_code]=postal       if postal
        pob[:county]=county            if county
        pob[:state]=state              if state
        pob[:country]=country          if country
        id=Place.collection.find_one_and_replace({:_id=>place[:formatted_address]},
              pob,
              {:upsert=>true, :return_document=>:after, :projection=>{:_id=>1}})
        pob[:_id]=id[:_id]
      else #just simulate from what we have
        pob=Place.collection.find.to_a.sample
      end

      Actor.collection.find(:_id=>doc[:_id]).update_one(:$set=>{:place_of_birth=>pob}, :$unset=>{:placeOfBirth=>""})
    end
  end

end
