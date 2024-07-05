# frozen_string_literal: true

require_relative "./test_helper"
require_relative "../../lib/lock/gemfile/rewriter"
require "rubygems"
require "ostruct"

module Lock
  class TestGemfile < Minitest::Test
    def setup
      @lockfile = {
        "rails" => "6.1.0",
        "puma" => "5.0.4",
        "rspec" => "3.10.0"
      }
      @rewriter = Lock::Gemfile::Rewriter.new
      @rewriter.lockfile = @lockfile
      @parser = Parser::Ruby31.new
    end

    def test_on_send_adds_version_specifier_when_missing
      buffer = Parser::Source::Buffer.new("(string)")
      buffer.source = "gem 'rails'"
      ast = @parser.parse(buffer)
      @output = @rewriter.rewrite(buffer, ast)
      assert_equal "gem 'rails', '6.1.0'", @output
    end

    def test_on_send_does_not_modify_version_specifier_when_present
      buffer = Parser::Source::Buffer.new("(string)")
      buffer.source = "gem 'puma', '5.0.4'"
      ast = @parser.parse(buffer)
      @output = @rewriter.rewrite(buffer, ast)
      assert_equal "gem 'puma', '5.0.4'", @output
    end

    def test_on_send_does_not_modify_non_gem_send_nodes
      buffer = Parser::Source::Buffer.new("(string)")
      buffer.source = "puts 'hello world'"
      ast = @parser.parse(buffer)
      @output = @rewriter.rewrite(buffer, ast)
      assert_equal "puts 'hello world'", @output
    end

    def test_on_send_does_not_add_version_specifier_when_gem_not_in_lockfile
      buffer = Parser::Source::Buffer.new("(string)")
      buffer.source = "gem 'nokogiri'"
      ast = @parser.parse(buffer)
      @output = @rewriter.rewrite(buffer, ast)
      assert_equal "gem 'nokogiri'", @output
    end

    def test_on_send_handles_multiple_gem_statements
      buffer = Parser::Source::Buffer.new("(string)")
      gemfile_content = <<~RUBY
        gem 'rails'
        gem 'puma', '5.0.4'
        gem 'rspec'
      RUBY
      buffer.source = gemfile_content
      ast = @parser.parse(buffer)
      @output = @rewriter.rewrite(buffer, ast)
      expected_result = <<~RUBY
        gem 'rails', '6.1.0'
        gem 'puma', '5.0.4'
        gem 'rspec', '3.10.0'
      RUBY
      assert_equal expected_result, @output
    end
  end
end
