require 'pg'
require 'active_support/inflector'
require_relative 'associatable'


#Your database
# Database = PG::Connection.open(:dbname => 'mvc')

class ModelBase
  extend Associations
  def initialize(params)
    params.each do |key, val|
      if self.class.columns.include?(key.to_sym)
        send((key + '=').to_sym, val)
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
    cols = Database.exec(<<-SQL)
    SELECT
      *
    FROM
      #{table_name}
    SQL
    @columns = cols.fields.map(&:to_sym)
  end

  def self.make_column_attr_accessors!
    columns.each do |col|
      define_method(col) do
        attributes[col]
      end

      define_method((col.to_s + '=').to_sym) do |obj|
        attributes[col] = obj
      end
    end
  end

  def self.all
    query_hash = Database.exec(<<-SQL)
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

  def attribute_values
    attributes.values
  end

  def self.find(id)
    binding.pry
    result = Database.exec(<<-SQL, [id])
      SELECT
       *
      FROM
        #{table_name}
      WHERE
       id = $1
    SQL
    new(result[0])
  end

  def insert
    col_names = self.class.columns.drop(1).map(&:to_s).join(', ')
    vals = (1..self.class.columns.length - 1)
           .to_a.map { |el| '$' + el.to_s }.join(', ')
    insertion = Database.each_params(<<-SQL, attribute_values.drop(1))
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{vals})
      RETURNING
        id
    SQL
    self.id = insertion[0]
  end

  def update
    set_line = self.class.columns
               .map { |col| col.to_s + '= ?' }.join(', ')
    Database.exec_params(<<-SQL, attribute_values)
    UPDATE
      #{self.class.table_name}
    SET
      #{set_line}
    WHERE
      id = #{self.id}
    SQL
  end

  def save
    id.nil? ? insert : update
  end

  def self.where(params)
    where_line = params.keys.map.with_index(1) { |key, idx| key.to_s + " = $#{idx}" }.join(' AND ')
    results = Database.exec(<<-SQL, params.values)
      SELECT
       *
      FROM
       #{table_name}
      WHERE
       #{where_line}
    SQL
    parse_all(results)
  end
end
