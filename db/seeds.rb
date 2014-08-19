# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
spaces = {
  :home => Space.create(:name => "Home", :description => "The home location"),
  :inn => Space.create(:name => "Inn", :description => "The village inn"),
}

Connection.create(:name => "to the inn", :from_id => spaces[:home].id, :to_id => spaces[:inn].id)
Connection.create(:name => "back home", :from_id => spaces[:inn].id, :to_id => spaces[:home].id)
