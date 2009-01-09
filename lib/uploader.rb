#
# 文件上传器
#

Dir.glob(File.join(File.dirname(__FILE__), 'album.rb'))
Dir.glob(File.join(File.dirname(__FILE__), 'file_finder.rb'))

require 'album'
require 'file_finder'

require 'rubygems'
require 'rest_client'

class Uploader
  # 用户ID
  @@USER_ID = '856'
  # 照片上传地址
  #@@PHOTO_UPLOAD_ADDRESS = 'http://localhost:3000/photos/create'
  # 相册建立地址
  #@@ALBUM_CREATE_ADDRESS = 'http://localhost:3000/albums/create'

  # 照片上传地址
  @@PHOTO_UPLOAD_ADDRESS = 'http://mmlou.com/photo/create'
  # 相册建立地址
  @@ALBUM_CREATE_ADDRESS = 'http://mmlou.com/album/only_create'

  #
  # 需要传入需要上传的目录
  #
  def initialize(dir)
    @dir = dir
  end

  #
  # 开始上传文件
  #
  def upload
    user_id = @@USER_ID
    file_finder = FileFinder.new(@dir)
    directories = file_finder.all_directories

    #
    # 建立一个album传入
    # 相册名,描述，user_id
    # 返回id
    # 
    # 把目录里的文件传入指定album_id里去
    # 返回album_id和pic_count
    #
    uploaded_albums = directories.map do |dir_name|
      ### create album ###########################################################
      puts 'ALBUM: ' + File.basename(dir_name)
      album_id = Album.create(@@ALBUM_CREATE_ADDRESS, user_id, File.basename(dir_name), dir_name)
      album = {:id => album_id, :name=> dir_name, :user_id => user_id}

      ### traversal all files for each directory #################################
      uploaded_pictures = file_finder.all_files(album[:name]).map do |file|
        
        unless is_uploaded?(file)
          ## 1 upload file
          puts "\t" + file
          command = "curl -F albumId=#{album[:id]} -F user_id=#{album[:user_id]} -F \"file=@#{file}\" #{@@PHOTO_UPLOAD_ADDRESS}"
          `#{command}`

          ## 2 add uploaded file record
          record_uploaded_file(file)
        end
      end

      ### return uploaded albums #################################################
      {:name=>album[:name], :pic_count=>uploaded_pictures.size}
    end
    return uploaded_albums
  end

  def is_uploaded?(file)
    upload_record = YAML.load_file("uploaded_photos.yaml")
    
    if upload_record.include?(file)
      true
    else
      false
    end    
  end

  def record_uploaded_file(file)
    upload_record = YAML.load_file("uploaded_photos.yaml")
    upload_record << file
    File.open 'uploaded_photos.yaml','w' do |t|
      t.write(upload_record.to_yaml)
    end
  end
end
