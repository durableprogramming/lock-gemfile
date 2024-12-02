require "minitest/autorun"
require "mocha/minitest"
require "lock/gemfile/report"

module Lock
  module Gemfile
    class TestReport < Minitest::Test
      def setup
        @report = Lock::Gemfile::Report.new
      end

      def test_generate
        @report.expects(:gem_count).returns(10)
        @report.expects(:locally_available_gemspec_count).returns(15)
        @report.expects(:remotely_available_gemspec_count).returns(20)
        @report.expects(:pct_of).with(5, 10).returns("50.0%")
        @report.expects(:pct_of).with(10, 10).returns("100.0%")

        expected_output = "Total gems: 10\n" \
                          "Matching gems locally available: 15 (50.0% extra)\n" \
                          "Matching gems remotely available: 20 (100.0% extra)\n"

        assert_output(expected_output) { @report.generate }
      end

      def test_gem_count
        @report.expects(:local_gemfile_dependencies).returns(Array.new(5))
        assert_equal 5, @report.send(:gem_count)
      end

      def test_locally_available_gemspec_count
        dep1 = mock
        dep1.expects(:name).returns("gem1")
        dep1.expects(:requirement).returns(Gem::Requirement.new(">= 1.0")).twice

        dep2 = mock
        dep2.expects(:name).returns("gem2")
        dep2.expects(:requirement).returns(Gem::Requirement.new(">= 2.0")).twice

        @report.expects(:local_gemfile_dependencies).returns([dep1, dep2])
        @report.expects(:local_versions_for).with("gem1").returns([Gem::Version.new("1.1"), Gem::Version.new("1.2")])
        @report.expects(:local_versions_for).with("gem2").returns([Gem::Version.new("1.9"), Gem::Version.new("2.1")])

        assert_equal 3, @report.send(:locally_available_gemspec_count)
      end

      def test_remotely_available_gemspec_count
        dep1 = mock
        dep1.expects(:name).returns("gem1")
        dep1.expects(:requirement).returns(Gem::Requirement.new(">= 1.0"))

        dep2 = mock
        dep2.expects(:name).returns("gem2")
        dep2.expects(:requirement).returns(Gem::Requirement.new(">= 2.0"))

        @report.expects(:local_gemfile_dependencies).returns([dep1, dep2])
        @report.expects(:remote_versions_for).with("gem1").returns([{ "number" => "1.1" }, { "number" => "1.2" }])
        @report.expects(:remote_versions_for).with("gem2").returns([{ "number" => "1.9" }, { "number" => "2.1" }])

        assert_equal 3, @report.send(:remotely_available_gemspec_count)
      end

      def test_pct_of
        assert_equal "50.0%", @report.send(:pct_of, 5, 10)
        assert_equal "200.0%", @report.send(:pct_of, 20, 10)
        assert_equal "0.0%", @report.send(:pct_of, 0, 10)
      end
    end
  end
end
