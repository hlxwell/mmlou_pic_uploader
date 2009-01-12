Dir.glob(File.join(File.dirname(__FILE__), 'uploader.rb'))
require 'uploader'
root = "/media/Hlxwell/6.Photos/12"
@uploader = Uploader.new(root)
photos_num, albums_num = @uploader.upload

puts "Uploaded #{photos_num} photos, and #{albums_num} albums."
