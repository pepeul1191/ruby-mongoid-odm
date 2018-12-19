require 'rubygems'
require 'bundler'
Bundler.require

Mongoid.configure do |config|
  config.clients.default = {
    hosts: ['localhost:27017'],
    database: 'schedules',
  }
  config.log_level = :warn
end

Mongoid.logger.level = Logger::DEBUG
Mongo::Logger.logger.level = Logger::INFO

class Schedule
  include Mongoid::Document
  store_in collection: 'schedules', database: 'schedules'
  field :day, type: Date
  field :transaction, type: String
end

Schedule.all.each do |test|
  puts test.to_json
end