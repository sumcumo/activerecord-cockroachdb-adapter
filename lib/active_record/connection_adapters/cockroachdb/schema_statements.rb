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
      end
    end
  end
end
