#
# 文件列举器，帮助找到文件目录中的所有文件夹和文件
# Directory tree:
# mmlou_pictures
#   /album1
#     /xxx0.jpg
#     /xxx1.jpg
#     /xxx2.jpg
#

require 'rubygems'

class FileFinder

  #
  # 传入需要寻找的目录
  #
  def initialize(root)
    if root =~ /\/$/
      @root = root
    else
      @root = root + '/'
    end    
  end

  #
  # 返回所有目录夹
  #
  def all_directories
    full_directories = []
    directories = Dir.entries(@root)
    
    #remove . and .. dir
    [".",".."].each do |dir|
      directories.delete(dir)
    end

    directories.each do |dir|
      if File.directory?(@root + dir)
        full_directories << @root + dir
      end
    end
    return full_directories
  end

  #
  # 返回指定目录下的所有文件
  # 参数：目录名
  #
  def self.all_files(dir)
    files = Dir.entries(dir)
    full_files = []

    files.each do |file|
      if File.file?(dir+'/'+file)
        full_files << dir+'/'+file
      end
    end
    
    return full_files
  end
end
