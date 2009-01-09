Dir.glob(File.join(File.dirname(__FILE__), 'uploader.rb'))
require 'uploader'
root = "/media/Hlxwell/6.Photos/13"
@uploader = Uploader.new(root)
result = @uploader.upload
puts result.inspect
