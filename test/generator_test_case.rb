# frozen_string_literal: true

require 'fileutils'

require_relative 'test_case'

class GeneratorTestCase < ::TestCase
  # @return [String]
  RAILS_PROJECT_PATH = 'test/dummy/rails7'
  # @return [String]
  RAILS_IMPORTMAP_PROJECT_PATH = 'test/dummy/rails7_importmap'
  # @return [String]
  RAILS_WEBPACK_PROJECT_PATH = 'test/dummy/rails7_webpack'
  # @return [String]
  COMPONENTS_ROOT_PATH = 'app/components'
  # @return [String]
  COMPONENTS_TEST_ROOT_PATH = 'test/components'
  # @return [String]
  INSTALL_GENERATOR = 'amber_component:install'
  # @return [String]
  COMPONENT_GENERATOR = 'component'

  # Object which represents the
  # currently tested git repo.
  #
  # @return [Git::Base]
  attr_reader :git

  private

  # @param path [String, Pathname]
  # @return [void]
  def setup_git_repo(path)
    @original_pwd = ::Dir.pwd
    # change the working directory to the Rails project root
    ::Dir.chdir path
    # initialize a new Git repo in the root of the Rails project
    @git = ::Git.init(::Dir.pwd)
    @git.add
    # commit the entire project
    @git.commit('.')
    assert @git.diff.none?
  end

  # @return [void]
  def reset_git_repo
    return unless @git

    # reset all the changes to the Rails project
    @git.clean(force: true)
    @git.reset_hard
    @git = nil
    # remove the Git repo
    ::FileUtils.rm_rf('.git')
    # restore the original working directory
    ::Dir.chdir @original_pwd
  end

  # @param command [String]
  # @return [Boolean]
  def rails(command)
    gemfile_path = ::File.expand_path 'Gemfile'
    system "BUNDLE_GEMFILE=#{gemfile_path} bundle exec rails #{command}"
  end

  # @param file_name [String]
  # @return [Git::Diff::DiffFile, nil]
  def file_diff(file_name)
    git.diff.entries.find { _1.path == file_name }
  end

  # @param args [Array<Symbol, String>]
  # @return [String]
  def component_test_path(*args)
    args.map! &:to_s

    ::File.join(COMPONENTS_TEST_ROOT_PATH, *args)
  end

  # @param args [Array<Symbol, String>]
  # @return [String]
  def component_path(*args)
    args.map! &:to_s

    ::File.join(COMPONENTS_ROOT_PATH, *args)
  end
end
