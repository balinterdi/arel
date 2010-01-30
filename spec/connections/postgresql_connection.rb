puts "Using native PostgreSQL"
$LOAD_PATH << '../do/data_objects/lib'
$LOAD_PATH << '../do/do_postgres/lib'
require 'data_objects'
require 'do_postgres'

DataObjects::Postgres.logger = DataObjects::Logger.new('debug.log', :debug)
at_exit { DataObjects.logger.flush }

@@conn = DataObjects::Connection.new("postgres://postgres@localhost/arel_unit?encoding=utf8")
