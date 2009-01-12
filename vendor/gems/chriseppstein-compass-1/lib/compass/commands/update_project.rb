require 'rubygems'
require 'sass'
require 'fileutils'
require 'pathname'
require File.join(File.dirname(__FILE__), 'base')

module Compass
  module Commands
    class UpdateProject < Base
      
      Base::ACTIONS << :compile
      Base::ACTIONS << :overwrite

      attr_accessor :project_directory, :project_name, :options, :project_src_subdirectory, :project_css_subdirectory

      def initialize(working_directory, options = {})
        super(working_directory, options)
        if options[:project_name]
          options[:project_name] = options[:project_name][0..-2] if options[:project_name][-1..-1] == File::SEPARATOR
          self.project_name = File.basename(options[:project_name])
          if options[:project_name][0] == File::SEPARATOR
            self.project_directory = options[:project_name]
          elsif File.directory?(File.join(working_directory, options[:project_name]))
            self.project_directory = File.expand_path(File.join(working_directory, options[:project_name]))
          else
            if File.exists?(options[:project_name]) or File.exists?(File.join(working_directory, options[:project_name]))
              raise ::Compass::Exec::ExecError.new("#{options[:project_name]} is not a directory.")
            elsif !(options[:force] || options[:dry_run])
              raise ::Compass::Exec::ExecError.new("#{options[:project_name]} does not exist.")
            end
          end
        else
          self.project_name = File.basename(working_directory)
          self.project_directory = working_directory          
        end
      end
      
      def perform
        read_project_configuration
        Dir.glob(separate("#{project_src_directory}/**/[^_]*.sass")).each do |sass_file|
          stylesheet_name = sass_file[("#{project_src_directory}/".length)..-6]
          compile "#{project_src_subdirectory}/#{stylesheet_name}.sass", "#{project_css_subdirectory}/#{stylesheet_name}.css", options
        end
      end

      # Compile one Sass file
      def compile(sass_filename, css_filename, options)
        sass_filename = projectize(sass_filename)
        css_filename = projectize(css_filename)
        if !File.directory?(File.dirname(css_filename))
          directory basename(File.dirname(css_filename)), options.merge(:force => true) unless options[:dry_run]
        end
        print_action :compile, basename(sass_filename)
        if File.exists?(css_filename)
          print_action :overwrite, basename(css_filename)
        else
          print_action :create, basename(css_filename)
        end
        unless options[:dry_run]
          engine = ::Sass::Engine.new(open(sass_filename).read,
                                      :filename => sass_filename,
                                      :line_comments => options[:environment] == :development,
                                      :style => output_style,
                                      :css_filename => css_filename,
                                      :load_paths => sass_load_paths)
          output = open(css_filename,'w')
          output.write(engine.render)
          output.close
        end
      end
      
      def output_style
        @output_style ||= options[:style] || if options[:environment] == :development
          :expanded
        else
          :compact
        end
      end

      # Read the configuration file for this project
      def read_project_configuration
        config_file = projectize('src/config.rb')
        if File.exists?(config_file)
          contents = open(config_file) {|f| f.read}
          eval(contents, nil, config_file)
        end
      end

      # where to load sass files from
      def sass_load_paths
        @sass_load_paths ||= [project_src_directory] + Compass::Frameworks::ALL.map{|f| f.stylesheets_directory}
      end
      
      # The subdirectory where the sass source is kept.
      def project_src_subdirectory
        @project_src_subdirectory ||= options[:src_dir] || "src"
      end

      # The subdirectory where the css output is kept.
      def project_css_subdirectory
        @project_css_subdirectory ||= options[:css_dir] || "stylesheets"
      end

      # The directory where the project source files are located.
      def project_src_directory
        @project_src_directory ||= separate("#{project_directory}/#{project_src_subdirectory}")
      end

    end
  end
end