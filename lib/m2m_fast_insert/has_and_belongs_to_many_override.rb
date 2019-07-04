module M2MFastInsert
  module HasAndBelongsToManyOverride
    # Decorate the original habtm to call our method definition
    #
    # name - Plural name of the model we're associating with
    # options - see ActiveRecord docs. Rails 4+ allows an optional proc in addition to the params
    def has_and_belongs_to_many(name, *options)
      super
      m2m_options = options.last.is_a?(Hash) ? options.last : {}
      define_fast_methods_for_model(name, m2m_options)
    end

    private
    # Get necessary table and column information so we can define
    # fast insertion methods
    #
    # name - Plural name of the model we're associating with
    # options - see ActiveRecord docs
    def define_fast_methods_for_model(name, options)
      join_table = options[:join_table]
      join_column_name = name.to_s.downcase.singularize
      define_method "fast_#{join_column_name}_ids_insert" do |*args|
        join_table ||= [join_column_name.pluralize, self.class.table_name].sort.join('_')
        table_name = self.class.table_name.singularize
        insert = M2MFastInsert::Base.new id, join_column_name, table_name, join_table, *args
        insert.fast_insert
      end
    end
  end
end

ActiveRecord::Base.send :extend, M2MFastInsert::HasAndBelongsToManyOverride
