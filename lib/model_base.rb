require 'active_support/inflector'
require 'pg'

database = PG.new

class ModelBase
  def initialize(params)
    params.each do |key, val|
      if self.class.columns.include?(k.to_sym)
        send((k + '=').to_sym, val)
      else
        fail("unknown attribute #{key}")
      end
    end
  end

  def self.table_name
    @@table_name ||= name.tableize
  end

  def self.table_name=(name)
    @@table_name = name
  end

  def self.columns
    return @columns if @columns
    cols = database.exec(<<-SQL)
    SELECT
    column_name
    FROM
    information_schema.columns
    WHERE
    table_name = #{self.table_name}
      SQL
    @columns = cols.fields.map(&:to_sym)
  end

  def self.make_column_attr_accessors!
    columns.each do |col|
      define_method(col) do
        attributes(col)
      end

      define_method((col.to_s + '-').to_sym) do |obj|
        attributes[col] = obj
      end
    end
  end

  def self.all
    query_hash = database.exec(<<-SQL)
    SELECT
    #{table_name}.*
    FROM
    #{table_name}
    SQL
    parse_all(query_hash)
  end

  def self.parse_all(query_hash)
    query_hash.map { |entry| new(entry) }
  end

  def attributes
    @attributes ||= {}
  end

  def self.find(id)
    result = database.exec(<<-SQL, [id])
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        id = $1
    SQL
    result.empty? ? nil : new(result[0])
  end
end
