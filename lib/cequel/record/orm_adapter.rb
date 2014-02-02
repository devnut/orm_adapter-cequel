module Cequel
  module Record
    #
    # ORM adapter for Cequel, the Ruby ORM for Cassandra
    #
    class OrmAdapter < ::OrmAdapter::Base
      extend Forwardable

      #
      # @return [Array<Symbol>] names of columns on this model
      #
      def column_names
        klass.columns.map { |column| column.name }
      end

      #
      # @param key_values [Array] values for each primary key column on this
      #   record
      # @return [Cequel::Record] a record instance corresponding to this
      #   primary key
      # @raise [Cequel::Record::RecordNotFound] if the key is not present
      #
      # @see #get
      #
      def get!(key_values)
        klass.find(*key_values)
      end

      #
      # @param key_values [Array] values for each primary key column on this
      #   record
      # @return [Cequel::Record] a record instance corresponding to this
      #   primary key or nil if not present
      #
      # @see #get
      #
      def get(key_values)
        get!(key_values)
      rescue Cequel::Record::RecordNotFound
        nil
      end

      #
      # Find the first record instance with the given conditions
      #
      # @param options [Options] options for query
      # @option options [Hash] :conditions map of column names to column
      #   values. This can either be a one-element hash specifying a secondary
      #   index lookup, or a mapping of primary key columns to values.
      # @return [Cequel::Record] the first record matching the query, or nil if
      #   none present
      #
      def find_first(options = {})
        construct_scope(options).first
      end

      #
      # Find all records with the given conditions and limit
      #
      # @param options [Options] options for query
      # @option options [Hash] :conditions map of column names to column
      #   values. This can either be a one-element hash specifying a secondary
      #   index lookup, or a mapping of primary key columns to values.
      # @option options [Integer] :limit maximum number of rows to return
      # @return [Array<Cequel::Record>] all records matching the conditions
      #
      def find_all(options = {})
        construct_scope(options).to_a
      end

      #
      # @!method create!(attributes = {})
      #   Create a new instance of the record class and save it to the database
      #
      #   @param attributes [Hash] map of column names to values
      #   @return [Cequel::Record] the newly created
      #   @raise [Cequel::Record::RecordInvalid] if the record fails
      #     validations
      #
      def_delegator :klass, :create!

      #
      # Destroy the given record
      #
      # @param record [Cequel::Record] the record to destroy
      # @return [void]
      #
      def destroy(record)
        record.destroy
      end

      private

      def construct_scope(options)
        conditions, _, limit, _ =
          extract_conditions!(options.deep_symbolize_keys)
        scope = klass.all
        scope = apply_secondary_index_scope(scope, conditions) ||
          apply_primary_key_scope(scope, conditions)
        scope = scope.limit(limit) if limit
        scope
      end

      def extract_conditions!(options)
        super.tap do |_, order, _, offset|
          if order.present?
            fail ArgumentError,
                 "Cassandra does not support ordering of results by " \
                 "arbitrary columns"
          end
          if offset.present?
            fail ArgumentError, 'Cassandra does not support row offsets'
          end
        end
      end

      def apply_primary_key_scope(scope, conditions)
        conditions = conditions.dup
        conditions.assert_valid_keys(*klass.key_column_names)

        klass.key_column_names.each do |column_name|
          column_value = conditions.delete(column_name)
          break unless column_value
          scope = scope[column_value]
        end

        assert_conditions_empty!(conditions)

        scope
      end

      def apply_secondary_index_scope(scope, conditions)
        return unless conditions.one?
        condition_column = klass.reflect_on_column(conditions.keys.first)
        if condition_column.data_column? && condition_column.indexed?
          scope.where(*conditions.first)
        end
      end

      def assert_conditions_empty!(conditions)
        unless conditions.empty?
          fail ArgumentError,
               "Invalid columns for conditions: #{conditions.keys.join(', ')}"
        end
      end
    end
  end
end
