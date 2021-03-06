require 'slim'

activate :autoprefixer, browsers: ['last 2 versions', 'ie 8', 'ie 9']
activate :livereload
activate :directory_indexes

activate :data_source do |c|
  c.root  = 'https://api.typeform.com/v1/form/JFjFWI?key=5e51d8be3d2cd649b3064ee34fabe2e8cd18d8cd&completed=true'
  c.files = [
    'rockstars.json'
  ]
end

set :js_dir,     'assets/javascripts'
set :css_dir,    'assets/stylesheets'
set :images_dir, 'assets/images'

page '/*.xml',  layout: false
page '/*.json', layout: false
page '/*.txt',  layout: false

# Dynamic pages
data.leaders.each do |leader|
  proxy "/#{leader.slug}.html", "/templates/leader.html", :locals => { :leader => leader }, :ignore => true
end

# Add bower's directory to sprockets asset path
after_configuration do
  @bower_config = JSON.parse(IO.read("#{root}/.bowerrc"))
  sprockets.append_path File.join "#{root}", @bower_config["directory"]
end

# Build-specific configuration
configure :build do
  activate :favicon_maker do |f|
    f.template_dir  = File.join(root, 'source/assets/images/logos/')
    f.output_dir    = File.join(root, 'build')
    f.icons = {
      'favicon_base.png' => [
        { icon: 'chrome-touch-icon-192x192.png' },
        { icon: 'apple-touch-icon.png', size: '152x152' },
        { icon: 'ms-touch-icon-144x144-precomposed.png', size: '144x144' },
        { icon: 'favicon-196x196.png' },
        { icon: 'favicon-160x160.png' },
        { icon: 'favicon-96x96.png' },
        { icon: 'favicon-32x32.png' },
        { icon: 'favicon-16x16.png' },
        { icon: 'favicon.ico', size: '64x64,32x32,24x24,16x16' },
      ]
    }
  end

  activate :minify_html, remove_input_attributes: false
  activate :minify_css
  activate :minify_javascript
  activate :gzip
  activate :asset_hash

  activate :sitemap, hostname: data.settings.site.url
  activate :sitemap_ping do |config|
    config.host = "#{data.settings.site.url}"
  end

  activate :robots,
    rules: [{:user_agent => '*', :allow => %w(/)}],
    sitemap: data.settings.site.url+'/sitemap.xml'

  # Use this for github.io gh-pages
  activate :relative_assets
  set :relative_links, true
end

# Push-it to the web
activate :deploy do |deploy|
  deploy.method       = :git
  deploy.branch       = 'gh-pages'
  deploy.build_before = true # always use --no-clean options

  committer_app = "#{Middleman::Deploy::PACKAGE} v#{Middleman::Deploy::VERSION}"
  commit_message = "Deployed using #{committer_app}"

  deploy.commit_message = commit_message
end
