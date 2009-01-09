#
# 文件上传器
#

Dir.glob(File.join(File.dirname(__FILE__), 'album.rb'))
Dir.glob(File.join(File.dirname(__FILE__), 'file_finder.rb'))

require 'album'
require 'file_finder'
require 'rubygems'
require 'rest_client'
require 'thread'

class Object
	def synchronize
		mutex.synchronize { yield self }
	end

	def mutex
		@mutex ||= Mutex.new
	end
end

class Uploader
  # 用户ID
  @@USER_ID = '859'

  # yaml 缓存已经上传的图片
  @@uploaded_photos = YAML.load_file("uploaded_photos.yaml")

  if true
    @@PHOTO_UPLOAD_ADDRESS = 'http://localhost:3000/photos/create'
    @@ALBUM_CREATE_ADDRESS = 'http://localhost:3000/albums/create'
  else
    @@PHOTO_UPLOAD_ADDRESS = 'http://mmlou.com:81/photo/create'
    @@ALBUM_CREATE_ADDRESS = 'http://mmlou.com:81/album/only_create'
  end

  # 超时时间
  @@timeout_seconds = 600

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

      @threads = []
      @files = file_finder.all_files(album[:name])
      uploaded_pictures = []
      
      50.times do |i|
        @threads << Thread.new do
          ##################################################
          while @files.size > 0
            file = nil
            # check out job 取任务的时候需要排队取
            @files.synchronize do
              begin
                file = @files.pop
              end while is_uploaded?(file)
            end

            # quit if no file get
            break unless file

            # check if uploaded
            # upload file and get photo id
            puts "\t uploading: " + file
            command = "curl -F albumId=#{album[:id]} -F user_id=#{album[:user_id]} -F \"file=@#{file}\" #{@@PHOTO_UPLOAD_ADDRESS} -m #{@@timeout_seconds}"
            photo_id = `#{command}`

            # check if timed out
            unless photo_id =~ /timed out/i
              # add uploaded file record
              record_uploaded_file(file)

              # we need this counter to get all uploaded photo
              uploaded_pictures << photo_id
            else
              next
            end
          end
          ###################################################
        end
      end

      @threads.each do |t|
        t.join
      end

      #      ### traversal all files for each directory #################################
      #      uploaded_pictures = file_finder.all_files(album[:name]).map do |file|
      #        # check if uploaded
      #        unless is_uploaded?(file)
      #          # upload file and get photo id
      #          puts "\t" + file
      #          command = "curl -F albumId=#{album[:id]} -F user_id=#{album[:user_id]} -F \"file=@#{file}\" #{@@PHOTO_UPLOAD_ADDRESS} -m #{@@timeout_seconds}"
      #          photo_id = `#{command}`
      #
      #          # check if timed out
      #          unless photo_id =~ /timed out/i
      #            # add uploaded file record
      #            record_uploaded_file(file)
      #            photo_id
      #          else
      #            next
      #          end
      #        end
      #      end


      ### return uploaded albums #################################################
      {:name=>album[:name], :pic_count=>uploaded_pictures.size}
    end
    
    return uploaded_albums
  end

  def is_uploaded?(file)
    return false if file.nil?
    # skip if not jpg
    return true unless File.basename(file) =~ /jpg/i

    if @@uploaded_photos.is_a?(Array) && @@uploaded_photos.include?(file)
      ### alert: file is uploaded
      puts "File Uploaded: #{file}"

      true
    else
      false
    end
  end

  def record_uploaded_file(filename)
    @@uploaded_photos = [] unless @@uploaded_photos.is_a?(Array)
    @@uploaded_photos << filename
    File.open 'uploaded_photos.yaml','w' do |t|
      t.write(@@uploaded_photos.to_yaml)
    end
    true
  rescue
    false
  end
end
