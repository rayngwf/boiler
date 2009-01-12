module Synthesis
  class AssetPackage

    private

    YUI_COMPRESSOR_PATH = "#{File.dirname(__FILE__)}/../yuicompressor"

    # compress Javascript with YUI Compressor
    def compress_js(source)
      tmp_path = "#{RAILS_ROOT}/tmp/#{@target}_packaged_uncompressed.js"
      File.open(tmp_path, "w") {|f| f.write(source) }
      result = `java -jar "#{YUI_COMPRESSOR_PATH}/build/yuicompressor-2.4.2.jar" --type js "#{tmp_path}"`
      File.delete(tmp_path) if File.exists?(tmp_path)
      result
    end

    # compress stylesheet with YUI Compressor
    def compress_css(source)
      tmp_path = "#{RAILS_ROOT}/tmp/#{@target}_packaged_uncompressed.css"
      File.open(tmp_path, "w") {|f| f.write(source) }
      result = `java -jar "#{YUI_COMPRESSOR_PATH}/build/yuicompressor-2.4.2.jar" --type css "#{tmp_path}"`
      File.delete(tmp_path) if File.exists?(tmp_path)
      result
    end

  end
end
