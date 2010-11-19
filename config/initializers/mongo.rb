# get yaml config
mongo_config = YAML.load( File.read(File.dirname(__FILE__) + '/../mongo.yml') )

# connect
MongoMapper.connection = Mongo::Connection.new(
  mongo_config[Rails.env]['domain'], 
  mongo_config[Rails.env]['port']
)
MongoMapper.database = mongo_config[Rails.env]['database']

# munge for Passenger
if defined?(PhusionPassenger)
   PhusionPassenger.on_event(:starting_worker_process) do |forked|
     MongoMapper.connection.connect_to_master if forked
   end
end