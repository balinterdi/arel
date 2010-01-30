puts "Using native SQLite3"
$LOAD_PATH << '../do/data_objects/lib'
$LOAD_PATH << '../do/do_sqlite3/lib'
require 'data_objects'
require 'do_sqlite3'

DataObjects::Sqlite3.logger = DataObjects::Logger.new('debug.log', :debug)
at_exit { DataObjects.logger.flush }

db_file = "spec/fixtures/fixture_database.sqlite3"

unless File.exist?(db_file)
  puts "SQLite3 database not found at #{db_file}. Rebuilding it."
  require 'fileutils'
  FileUtils.mkdir_p(File.dirname(db_file))
  sqlite_command = %Q{sqlite3 "#{db_file}" "create table a (a integer); drop table a;"}
  puts "Executing '#{sqlite_command}'"
  raise "Seems that there is no sqlite3 executable available" unless system(sqlite_command)
end

@@conn = DataObjects::Connection.new("sqlite3://#{File.expand_path(db_file)}")
