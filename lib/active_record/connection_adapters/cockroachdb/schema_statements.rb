# frozen_string_literal: true

require 'active_record/connection_adapters/postgresql/schema_statements'

module ActiveRecord
  module ConnectionAdapters
    module CockroachDB
      module SchemaStatements
        include ActiveRecord::ConnectionAdapters::PostgreSQL::SchemaStatements

        # copied from ActiveRecord::ConnectionAdapters::SchemaStatements
        #
        # modified insert into statement to always wrap the version value into single quotes for cockroachdb.
        def assume_migrated_upto_version(version, migrations_paths = nil)
          unless migrations_paths.nil?
            ActiveSupport::Deprecation.warn(<<~MSG.squish)
              Passing migrations_paths to #assume_migrated_upto_version is deprecated and will be removed in Rails 6.1.
            MSG
          end

          version = version.to_i
          sm_table = quote_table_name(schema_migration.table_name)

          migrated = migration_context.get_all_versions
          versions = migration_context.migrations.map(&:version)

          unless migrated.include?(version)
            execute insert_versions_sql(version.to_s)
          end

          inserting = (versions - migrated).select { |v| v < version }
          if inserting.any?
            if (duplicate = inserting.detect { |v| inserting.count(v) > 1 })
              raise "Duplicate migration #{duplicate}. Please renumber your migrations to resolve the conflict."
            end

            execute insert_versions_sql(inserting.map(&:to_s))
          end
        end

        # copied from ActiveRecord::PostgreSQL::SchemaStatements
        #
        # - removed the algortithm part from the DROP INDEX statement
        # - added CASCADE because cockroach won't drop a UNIQUE constrain without
        def remove_index(table_name, options = {})
          table = PostgreSQL::Utils.extract_schema_qualified_name(table_name.to_s)

          if options.is_a?(Hash) && options.key?(:name)
            provided_index = PostgreSQL::Utils.extract_schema_qualified_name(options[:name].to_s)

            options[:name] = provided_index.identifier
            table = PostgreSQL::Name.new(provided_index.schema, table.identifier) unless table.schema.present?

            if provided_index.schema.present? && table.schema != provided_index.schema
              raise ArgumentError, "Index schema '#{provided_index.schema}' does not match table schema '#{table.schema}'"
            end
          end

          index_to_remove = PostgreSQL::Name.new(table.schema, index_name_for_remove(table.to_s, options))
          execute "DROP INDEX #{quote_table_name(index_to_remove)} CASCADE"
        end
      end
    end
  end
end
