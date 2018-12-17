require 'rubygems'
require 'bundler'
Bundler.require

MongoMapper.connection = Mongo::Connection.new('127.0.0.1', 27017)
MongoMapper.database = 'ubicaciones'

class Location
  include ::ActiveModel::Serialization
  include ::ActiveModel::Serializers::Xml
  include ::ActiveModel::Serializers::JSON
  include MongoMapper::Document
  connection(Mongo::Connection.new('localhost', 27017))
  set_database_name 'ubicaciones'
  set_collection_name 'ubicaciones'

  key :nombre, String
  key :tipo, String
  key :pais_id, String
  key :departamento_id, String
  key :provincia_id, String
end

def query
  begin
    locations = Location.all(:tipo => 'departamento')
    locations.each do |doc|
      #puts doc.nombre
      #puts doc.provincia_id
      puts doc.to_json
    end
  rescue MongoMapper::Error => e
    error = true
    execption = e
    puts e
  end
end

query
