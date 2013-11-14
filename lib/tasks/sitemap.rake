namespace :sitemap do
  task :generate => :environment do
    sitemap = Sitemap.create!(SITE_URL)
  end
end
