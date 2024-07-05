# frozen_string_literal: true

require "parser/ruby31"

module Lock
  module Gemfile
    # The Lock::Gemfile::Rewriter class is a subclass of
    # Parser::TreeRewriter that rewrites a Gemfile's Abstract Syntax
    # Tree (AST) to include locked gem versions from a corresponding
    # Gemfile.lock file.
    #
    # The rewriter traverses the AST and looks for `gem` method calls. For
    # each `gem` call found, it checks if a version specifier is already
    # present. If not, it retrieves the locked version from the provided
    # lockfile hash and inserts a version specifier string after the
    # gem name.
    #
    # The version specifier can be either pessimistic or exact, depending
    # on the value of the `pessimistic` attribute. If `pessimistic` is
    # true (default), the version specifier will be prefixed with "~>",
    # otherwise it will be an exact version.
    #
    # Example usage:
    #
    #   parser = Parser::Ruby31.new ast = parser.parse(buffer)
    #
    #   rewriter = Lock::Gemfile::Rewriter.new rewriter.lockfile = {
    #     "rails" => "6.1.0", "puma" => "5.0.4"
    #   } rewriter.pessimistic = true
    #
    #   modified_ast = rewriter.rewrite(buffer, ast)
    #
    # Attributes:
    #   lockfile (Hash): A hash containing gem names as keys and their
    #   locked versions as values.  pessimistic (Boolean): Determines
    #   whether to use pessimistic version specifiers. Default is true.
    #
    # Methods:
    #   on_send(node): Called when a `:send` node is encountered in the
    #   AST. Checks if the node represents a `gem` method call
    #                  and inserts the locked version specifier if
    #                  applicable.
    class Rewriter < Parser::TreeRewriter
      attr_accessor :lockfile, :pessimistic

      # Handles `:send` nodes in the AST, which represent method calls.
      #
      # If the node is a `gem` method call and doesn't already have
      # a version specifier, retrieves the locked version from the
      # `lockfile` hash and inserts a version specifier string.
      #
      # The version specifier can be either pessimistic or exact,
      # depending on the value of `pessimistic`.
      #
      # Arguments:
      #
      #   node (Parser::AST::Node): The `:send` node being processed.
      #
      def on_send(node)
        return unless node.type == :send && node.children[1] == :gem

        gem_name = node.children[2].children[0]

        old_version_specifier = node.children[3]
        already_has_version_specifier = old_version_specifier && old_version_specifier.type == :str

        return if already_has_version_specifier

        lockfile_gem_details = lockfile[gem_name]
        new_version_specifier = lockfile_gem_details&.to_s
        prefix = if pessimistic
                   "~> "
                 else
                   ""
                 end

        return unless new_version_specifier

        insert_after(node.children[2].location.end, ", '#{prefix}#{new_version_specifier}'")
      end
    end
  end
end
