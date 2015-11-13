class AssocSupport
  attr_accessor :foreign_key, :class_name, :primary_key

  def model_class
    @class_name.constantize
  end
end

class BelongsTo < AssocSupport
  def initialize(name, options = {})
    @foreign_key = options[:foreign_key] || "#{name}_id".to_sym
    @primary_key = :id
    @class_name = options[:class_name] || name.to_s.singularize.camelcase
  end
end

class HasMany < AssocSupport
  def initialize(name, class_name, options = {})
    @foreign_key = options[:foreign_key] || "#{class_name}_id".to_sym
    @primary_key = :id
    @class_name = options[:class_name] || name.to_s.singularize.camelcase
  end
end

module Associations
  def belongs_to(name, options = {})
    associations_hash[name] = BelongsTo.new(name, options)
    define_method(name) do
      association = self.class.associations_hash[name]
      association.model_class.where(:id => post_id)[0]
    end
  end

  def has_many(name, options = {})
    associations_hash[name] = HasMany.new(name, self.name, options)
    define_method(name) do
      association = self.class.associations_hash[name]
      association.model_class.where(association.foreign_key => id)
    end
  end

  def associations_hash
    @associations ||= {}
  end
end
