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

def aggregate
  search = 'Pueblo'
  pipeline = [
    {
      '$match':  {
        'tipo':  'distrito'
      }
    },
    {
      '$lookup':  {
        'from':  'ubicaciones',
        'localField':  'provincia_id',
        'foreignField':  '_id',
        'as':  'provincia'
      }
    },
    {
      '$unwind':  {
        'path':  '$provincia',
        'preserveNullAndEmptyArrays':  true
      }
    },
    {
      '$lookup':  {
        'from':  'ubicaciones',
        'localField':  'provincia.departamento_id',
        'foreignField':  '_id',
        'as':  'departamento'
      }
    },
    {
      '$unwind':  {
        'path':  '$departamento',
        'preserveNullAndEmptyArrays':  true
      }
    },
    {
      '$match': {
        'departamento.pais_id':  BSON::ObjectId('5be31406ef095142e0df0a9c'),
        'nombre':  {
          '$regex':  search + '.*'
        }
      }
    },
    {
      '$project':  {
        '_id':  '$_id',
        'nombre':  {
          '$concat':  [
            '$nombre',
            ', ',
            '$provincia.nombre',
            ', ',
            '$departamento.nombre'
          ]
        },
      }
    },
    {
      '$limit':  10
    },
  ]
  cursor = Location.collection.aggregate(pipeline);
  cursor.each do |document|
    puts document
  end
end

#list
aggregate
