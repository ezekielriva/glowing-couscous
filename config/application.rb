require 'bundler/setup'
require 'singleton'
require 'logger'
require 'yaml'

class App
  include Singleton

  attr_accessor :database_connection, :root_path, :env, :temp_path,
                :logger_file, :logger, :paths

  def initialize
    @root_path   = Dir.pwd
    @env         = ENV['RACK_ENV'] || :development
    @temp_path   = "#{root_path}/temp"
    @logger_file = "#{root_path}/logs/#{env}.log"
    @logger      = Logger.new(logger_file, 'monthly')
    @paths       = ['app']
  end

  def connection_config
    ActiveRecord::Base.connection_config
  end

  def init &block
    connect_database!
    klass = Class.new(Grape::API)
    klass.instance_eval &block
    klass
  end

  # Take from File activesupport/lib/active_support/inflector/methods.rb, line 90
  def underscore(camel_cased_word)
    return camel_cased_word unless camel_cased_word =~ /[A-Z-]|::/
    word = camel_cased_word.to_s.gsub(/::/, '/')
    acronym_regex = /(?=a)b/
    word.gsub!(/(?:(?<=([A-Za-z\d]))|\b)(#{acronym_regex})(?=\b|[^a-z])/) { "#{$1 && '_'}#{$2.downcase}" }
    word.gsub!(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2')
    word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
    word.tr!("-", "_")
    word.downcase!
    word
  end

  private

  def database_file
    File.open("#{root_path}/db/database.yml", 'r')
  end

  def connect_database!
    @database_connection = ActiveRecord::Base.establish_connection(database_configuration)
    ActiveRecord::Base.logger = ActiveSupport::Logger.new(STDOUT)
  end

  def database_configuration
    loaded_file = YAML.load_file(database_file)
    loaded_file.fetch(env)
  end

end

app = App.instance

Bundler.require(:default, app.env)

file_paths = app.paths.join(',')
glob       = "#{app.root_path}/{#{file_paths}}/**/*.rb"
Dir.glob(glob).each do |file|
  begin
    require file
  rescue NameError => e
    missing_file = app.underscore(e.name)
    Dir.glob("#{app.root_path}/**/#{missing_file}.rb").each {|file| require file}
    retry
  end
end
