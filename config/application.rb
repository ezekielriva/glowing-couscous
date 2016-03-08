require 'bundler/setup'
require 'singleton'
require 'logger'

class App
  include Singleton

  def root_path
    @root_path ||= Dir.pwd
  end

  def env
    @env ||= (ENV['RACK_ENV'] || :development)
  end

  def temp_path
    @temp_path ||= "#{root_path}/temp"
  end

  def logger_file
    @logger_file ||= "#{ROOT_PATH}/logs/#{env}.log"
  end

  def logger
    @logger ||= Logger.new(logger_file, 'monthly')
  end

  def paths
    ['app']
  end

  def init &block
    klass = Class.new(Grape::API)
    klass.instance_eval &block
    klass
  end
end

app = App.instance

Bundler.require(:default, app.env)

file_paths = app.paths.join(',')
glob       = "#{app.root_path}/{#{file_paths}}/**/*.rb"
Dir.glob(glob).each { |file| require file }
