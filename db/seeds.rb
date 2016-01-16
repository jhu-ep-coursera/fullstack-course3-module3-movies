# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require 'json/pure'
Mongo::Logger.logger.level = ::Logger::INFO
Actor.collection.find.delete_many
Movie.collection.find.delete_many
Director.collection.find.delete_many
Writer.collection.find.delete_many
Place.collection.find.delete_many
Actor.create_indexes
Place.create_indexes

puts "adding places"
JSON.parse(File.read('db/places.json')).each do |doc|
  Place.collection.insert_one(doc)
end

puts "adding actors"
JSON.parse(File.read('db/actors.json')).each do |doc|
  date_of_birth=doc["date_of_birth"]
  if date_of_birth
    mongo_date = date_of_birth["$date"]
    iso8601=Date.xmlschema(mongo_date)
    doc["date_of_birth"]=iso8601
  end
  Actor.collection.insert_one(doc)
end

puts "adding writers"
JSON.parse(File.read('db/writers.json')).each do |doc|
  Writer.collection.insert_one(doc)
end

puts "adding directors"
JSON.parse(File.read('db/directors.json')).each do |doc|
  Director.collection.insert_one(doc)
end

puts "adding movies"
JSON.parse(File.read('db/movies.json')).each do |doc|
  release_date=doc["release_date"]
  if release_date && release_date["$date"]
    mongo_date = release_date["$date"]
    iso8601=Date.xmlschema(mongo_date)
    doc["release_date"]=iso8601
  end
  Movie.collection.insert_one(doc)
end
