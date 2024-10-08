require 'optparse'
require_relative 'rewriter'
require_relative 'report'

module Lock
  module Gemfile
    class CLI
      def self.run(args)
        new.run(args)
      end

      def run(args)
        options = parse_options(args)

        case options[:command]
        when 'report'
          Report.generate
        when 'rewrite'
          rewrite_gemfile(options)
        else
          puts "Unknown command: #{options[:command]}"
          exit 1
        end
      end

      private

      def parse_options(args)
        options = { pessimistic: true }
        
        OptionParser.new do |opts|
          opts.banner = "Usage: lock [options] <command>"

          opts.on("-e", "--exact", "Use exact version instead of pessimistic") do
            options[:pessimistic] = false
          end

          opts.on("-h", "--help", "Show this message") do
            puts opts
            exit
          end
        end.parse!(args)

        options[:command] = args.shift

        options
      end

      def rewrite_gemfile(options)
        gemfile_path = 'Gemfile'
        lockfile_path = 'Gemfile.lock'

        unless File.exist?(gemfile_path) && File.exist?(lockfile_path)
          puts "Gemfile or Gemfile.lock not found in current directory"
          exit 1
        end

        gemfile_content = File.read(gemfile_path)
        lockfile_content = File.read(lockfile_path)

        parser = Parser::Ruby31.new
        buffer = Parser::Source::Buffer.new(gemfile_path)
        buffer.source = gemfile_content
        ast = parser.parse(buffer)

        lockfile = parse_lockfile(lockfile_content)

        rewriter = Lock::Gemfile::Rewriter.new
        rewriter.lockfile = lockfile
        rewriter.pessimistic = options[:pessimistic]

        modified_gemfile = rewriter.rewrite(buffer, ast)

        File.write(gemfile_path, modified_gemfile)
        puts "Gemfile updated with locked versions"
      end

      def parse_lockfile(content)
        specs = content.split("DEPENDENCIES").first.split("\n")
        specs.each_with_object({}) do |line, hash|
          if line =~ /^\s{4}(\S+) \((.*?)\)/
            hash[$1] = $2
          end
        end
      end
    end
  end
end
