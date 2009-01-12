require File.dirname(__FILE__) + "/../lib/asset_packager_extension"

namespace :compass do

  desc "Compile SASS"
  task :compile => :build_grid do
    require "#{RAILS_ROOT}/config/initializers/compass"
	  Sass::Plugin.options[:template_location].each do |from_dir, to_dir|
	    next unless from_dir.start_with?(File.join(RAILS_ROOT, "app"))
	    from_dir, to_dir = [from_dir, to_dir].map { |d| Pathname.new(d) }
	    Pathname.glob("#{from_dir}/**/*.sass").each do |sass_file|
        basename = sass_file.relative_path_from(from_dir).basename.sub(/\.sass$/i, "")
        css_filename = "#{to_dir}/#{basename}.css"
        engine = Sass::Engine.new(sass_file.read,
          :filename => sass_file,
          :line_comments => false,
          :css_filename => css_filename,
          :load_paths => [from_dir] + Compass::Frameworks::ALL.map{ |f| f.stylesheets_directory }
        )
        FileUtils.mkdir_p(File.dirname(css_filename))
        open(css_filename, 'w') do |output|
          output.write(engine.render)
          puts "Created #{css_filename}"
        end
      end
    end
  end

  desc "Build Grid"
  task :build_grid => :environment do
    output_path = "#{RAILS_ROOT}/public/images"
    require "#{Gem::GemPathSearcher.new.find('compass').full_gem_path}/frameworks/blueprint/lib/blueprint/grid_builder"
    Blueprint::GridBuilder.new(:column_width => 30, :gutter_width => 10, :output_path => output_path).generate!
    puts "Created #{output_path}/grid.png"
  end

end

namespace :asset do

  desc "Compile all assets"
  task :compile => ["compass:compile", "asset:packager:build_all"]

end