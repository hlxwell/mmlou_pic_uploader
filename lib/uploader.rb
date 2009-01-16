#
# 文件上传器
#
require 'album'
require 'file_finder'
require 'rubygems'
require 'thread'

class Object
	def synchronize
		mutex.synchronize { yield self }
	end

	def mutex
		@mutex ||= Mutex.new
	end
end

#
# 上传图片
# TODO: upload manager
#

class Uploader
  # 用户ID
  @@USER_ID = '875'

  # yaml 缓存已经上传的图片
  @@uploaded_photos = []

  if false
    @@PHOTO_UPLOAD_ADDRESS = 'http://localhost:3000/photos/create'
    @@ALBUM_CREATE_ADDRESS = 'http://localhost:3000/albums/create'
  else
    @@PHOTO_UPLOAD_ADDRESS = 'http://mmlou.com:81/photo/create'
    @@ALBUM_CREATE_ADDRESS = 'http://mmlou.com:81/album/only_create'
  end

  # 超时时间
  @@timeout_seconds = 60

  #
  # 需要传入需要上传的目录
  #
  def initialize(dir)
    @dir = dir
    @@uploaded_photos = Uploader.load_yaml_file()
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
    switch = false
    uploaded_albums = directories.map do |dir_name|
      ### create album ###########################################################
      puts "\n ALBUM: " + File.basename(dir_name)

      #选择从哪个目录开始传
#      if dir_name =~ /SAYURI_ANZU_in_Thailand/i or switch
#        switch = true
#      else
#        next
#      end
      
      @files = FileFinder.all_files(dir_name)
      if is_all_files_uploaded?(@files)
        next
      else
        album_id = Album.create(@@ALBUM_CREATE_ADDRESS, user_id, File.basename(dir_name), File.basename(dir_name))
      end

      album = {:id => album_id, :name=> File.basename(dir_name), :user_id => user_id}

      @threads = []
      uploaded_pictures = []
      
      10.times do |i|
        @threads << Thread.new do
          ### Thread start #####################################
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
            puts "\nThread-#{i} uploading: " + file
            command = "curl -F albumId=#{album[:id]} -F tags=\"#{album[:name]}\" -F user_id=#{album[:user_id]} -F \"file=@#{file}\" #{@@PHOTO_UPLOAD_ADDRESS} -m #{@@timeout_seconds}"
            photo_id = `#{command}`

            # check if timed out            
            if photo_id == 'true'
              @@uploaded_photos.synchronize do
                # add uploaded file record
                while not record_uploaded_file(file)
                end

                # we need this counter to get all uploaded photo
                uploaded_pictures << photo_id
                puts "\nThread-#{i} uploaded: " + file
              end
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

      ### return uploaded albums #################################################
      {:name=>album[:name], :pic_count=>uploaded_pictures.size}
    end

    photos_num = 0
    uploaded_albums.each do |album|
      photos_num += album[:pic_count].to_i if album
    end
    return photos_num, uploaded_albums.size
  end

  def record_uploaded_file(filename)
    @@uploaded_photos = [] unless @@uploaded_photos.is_a?(Array)
    @@uploaded_photos << filename
    File.open 'uploaded_photos.yaml','w' do |t|
      t.write(@@uploaded_photos.to_yaml)
    end
    #backup
    File.open 'uploaded_photos.yaml.bak','w' do |t|
      t.write(@@uploaded_photos.to_yaml)
    end
    true
  rescue
    false
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

  def is_all_files_uploaded?(files)
    files.each do |file|
      unless is_uploaded?(file)
        return false
      end
    end
    true
  end

  def self.load_yaml_file
    record = File.size("uploaded_photos.yaml")
    bak_record = File.size("uploaded_photos.yaml.bak")

    if record >= bak_record
      YAML.load_file("uploaded_photos.yaml")
    else
      YAML.load_file("uploaded_photos.yaml.bak")
    end
  end
end
