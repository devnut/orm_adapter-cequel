require 'bundler'
Bundler.require(:default, :development)

RSpec.configure do |config|
  config.before :all do
    Cequel::Record.establish_connection(keyspace: 'orm_helper_cequel')
    Cequel::Record.connection.schema.create!
    Cequel::Record.connection.logger = Logger.new(STDOUT) if ENV['LOG_QUERIES']

    Dir.glob(File.expand_path('../../models/**/*.rb', __FILE__)).each do |model|
      require model
      File.basename(model, '.rb').classify.constantize.synchronize_schema
    end
  end

  config.after :each do
    Dir.glob(File.expand_path('../../models/**/*.rb', __FILE__)).each do |model|
      File.basename(model, '.rb').classify.constantize.destroy_all
    end
  end

  config.after :all do
    Cequel::Record.connection.schema.drop!
  end
end
