# load data from seeds.rb for testing database rather than fixtures
# http://stackoverflow.com/a/1829515/39531
namespace :db do
  namespace :test do
    task :load => :environment do
      Rake::Task["db:seed"].invoke
      puts "Loaded db:seed data"
    end
  end
end
