# NOTE: Column/Metadata API should be implemented upstream
class Column
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def type_cast(value)  # Stub
    value
  end

end

module Arel
  module Sql
    class Engine

      IDENTIFIER_MAX_LENGTH = 128

      attr_reader :connection

      def initialize(conn = nil)
        @connection = conn
      end

      # NOTE: Obviously, this should be implemented upstream! This is quick and
      #       dirty implementation to get things working.
      def columns(table_name, name = nil)#:nodoc:
        columns = []
        if defined?(DataObjects::Sqlite3)
          column_name, columns_sql = 'name', "PRAGMA table_info(#{table_name})"
        elsif defined?(DataObjects::Postgres)
          column_name, columns_sql = 'attname', <<-SQL
            SELECT a.attname, format_type(a.atttypid, a.atttypmod), d.adsrc, a.attnotnull
              FROM pg_attribute a LEFT JOIN pg_attrdef d
                ON a.attrelid = d.adrelid AND a.attnum = d.adnum
             WHERE a.attrelid = '#{quote_table_name(table_name)}'::regclass
               AND a.attnum > 0 AND NOT a.attisdropped
             ORDER BY a.attnum
          SQL
        else # MySQL
          column_name, columns_sql = 'Field', "SHOW FIELDS FROM #{quote_table_name(table_name)}"
        end
        reader = @connection.create_command(columns_sql).execute_reader
        reader.each { |r| columns << Column.new(r[column_name]) }
        columns
      end

      def quote_table_name(name) #:nodoc:
        if defined?(DataObjects::Mysql)
          "`#{name[0, self.class::IDENTIFIER_MAX_LENGTH].gsub('`', '``')}`"
        else
          "\"#{name[0, self.class::IDENTIFIER_MAX_LENGTH].gsub('"', '""')}\""
        end
      end

      def quote_column_name(name)
        quote_table_name(name.to_s)
      end

      def quote(value, column = nil)
        @connection.quote_value(value)
      end

      def adapter_name
        'DataObjects'
      end

      module CRUD
        def create(relation)
          connection.create_command(relation.to_sql).execute_non_query
        end

        def read(relation)
          reader = connection.create_command(relation.to_sql).execute_reader
          rows   = []
          begin
            while reader.next!
              rows << reader.values
            end
          ensure
            reader.close
          end
          Array.new(rows, relation.attributes)
        end

        def update(relation)
          connection.create_command(relation.to_sql).execute_non_query
        end

        def delete(relation)
          connection.create_command(relation.to_sql).execute_non_query
        end
      end
      include CRUD
    end
  end
end
