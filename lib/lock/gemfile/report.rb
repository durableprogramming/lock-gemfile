require "bundler"
require "net/http"
require "uri"
require "json"

module Lock
  module Gemfile
    class Report
      def self.generate
        new.generate
      end

      def generate
        total_gems = gem_count
        local_gems = locally_available_gemspec_count
        remote_gems = remotely_available_gemspec_count

        puts "Total gems: #{total_gems}"
        puts "Matching gems locally available: #{local_gems} (#{pct_of(local_gems - total_gems, total_gems)} extra)"
        puts "Matching gems remotely available: #{remote_gems} (#{pct_of(remote_gems - total_gems, total_gems)} extra)"
      end

      private

      def gem_count
        @gem_count ||= local_gemfile_dependencies.length
      end

      def locally_available_gemspec_count
        local_gemfile_dependencies.sum do |dep|
          local_versions_for(dep.name).count do |version|
            dep.requirement.satisfied_by?(version)
          end
        end
      end

      def remotely_available_gemspec_count
        local_gemfile_dependencies.sum do |dependency|
          constraint = dependency.requirement
          versions = remote_versions_for(dependency.name)

          versions.count do |version_data|
            constraint.satisfied_by?(Gem::Version.new(version_data["number"]))
          end
        end
      end

      def remote_versions_for(gem_name)
        uri = URI("https://rubygems.org/api/v1/versions/#{gem_name}.json")
        response = Net::HTTP.get(uri)
        JSON.parse(response)
      end

      def local_versions_for(gem_name)
        Gem::Specification.find_all_by_name(gem_name).map(&:version)
      end

      def local_gemfile_dependencies
        Bundler.definition.dependencies
      end

      def pct_of(a, b)
        (((a.to_f / b.to_f) * 100)).round(2).to_s + "%"
      end
    end
  end
end
