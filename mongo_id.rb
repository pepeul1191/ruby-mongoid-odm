require 'rubygems'
require 'bundler'
Bundler.require

Mongoid.configure do |config|
  config.clients.default = {
    hosts: ['localhost:27017'],
    database: 'ubicaciones',
  }

  config.log_level = :warn
end

Mongoid.logger.level = Logger::DEBUG
Mongo::Logger.logger.level = Logger::INFO

class Location
  include Mongoid::Document
  store_in collection: 'ubicaciones', database: 'ubicaciones'
  field :nombre, type: String
  field :tipo, type: String
  field :pais_id, type: String
  field :departamento_id, type: String
  field :provincia_id, type: String
end

def list
  Location.all.where(tipo: 'departamento').each do |test|
    puts test.to_json
  end
end

list
