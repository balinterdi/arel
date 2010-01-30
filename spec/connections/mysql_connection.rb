puts "Using native MySQL"
$LOAD_PATH << '../do/data_objects/lib'
$LOAD_PATH << '../do/do_mysql/lib'
require 'data_objects'
require 'do_mysql'

DataObjects::Mysql.logger = DataObjects::Logger.new('debug.log', :debug)
at_exit { DataObjects.logger.flush }

@@conn = DataObjects::Connection.new("mysql://localhost/arel_unit?encoding=utf8")
