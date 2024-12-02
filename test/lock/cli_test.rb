require "minitest/autorun"
require "mocha/minitest"
require "lock/gemfile/cli"

module Lock
  module Gemfile
    class CLITest < Minitest::Test
      def setup
        @cli = CLI.new
      end

      def test_run_report
        Report.expects(:generate)
        @cli.run(["report"])
      end

      def test_run_rewrite
        @cli.expects(:rewrite_gemfile).with(pessimistic: true, command: "rewrite")
        @cli.run(["rewrite"])
      end

      def test_run_rewrite_with_exact_option
        @cli.expects(:rewrite_gemfile).with(pessimistic: false, command: "rewrite")
        @cli.run(["rewrite", "-e"])
      end

      def test_run_unknown_command
        assert_output(/Unknown command: unknown\n/) do
          assert_raises(SystemExit) { @cli.run(["unknown"]) }
        end
      end

      def test_parse_options
        options = @cli.send(:parse_options, ["-e", "rewrite"])
        assert_equal false, options[:pessimistic]
        assert_equal "rewrite", options[:command]
      end

      def test_rewrite_gemfile
        File.expects(:exist?).with("Gemfile").returns(true)
        File.expects(:exist?).with("Gemfile.lock").returns(true)
        File.expects(:read).with("Gemfile").returns('gem "rails"')
        File.expects(:read).with("Gemfile.lock").returns("GEM\n  remote: https://rubygems.org/\n  specs:\n    rails (6.1.0)\n")

        Parser::Ruby31.any_instance.expects(:parse).returns(mock)
        Lock::Gemfile::Rewriter.any_instance.expects(:rewrite).returns('gem "rails", "~> 6.1.0"')

        File.expects(:write).with("Gemfile", 'gem "rails", "~> 6.1.0"')

        assert_output(/Gemfile updated with locked versions\n/) do
          @cli.send(:rewrite_gemfile, pessimistic: true)
        end
      end

      def test_parse_lockfile
        lockfile_content = <<~LOCKFILE
          GEM
            remote: https://rubygems.org/
            specs:
              rails (6.1.0)
              puma (5.0.4)

          PLATFORMS
            ruby

          DEPENDENCIES
            puma
            rails
        LOCKFILE

        expected_result = {
          "rails" => "6.1.0",
          "puma" => "5.0.4"
        }

        assert_equal expected_result, @cli.send(:parse_lockfile, lockfile_content)
      end
    end
  end
end
