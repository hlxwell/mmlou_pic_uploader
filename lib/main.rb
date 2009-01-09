Dir.glob(File.join(File.dirname(__FILE__), 'uploader.rb'))
require 'uploader'
#root = "/media/Hlxwell/6.Photos/TEST"
root = "/home/hlxwell/mmlou_pictures"
@uploader = Uploader.new(root)
result = @uploader.upload
puts result.inspect
