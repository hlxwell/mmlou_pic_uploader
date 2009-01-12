#
# 远程相册管理
#

require 'rubygems'

class Album
  # 静态方法
  # 创建相册
  def self.create(address, user_id, name, description)
    #TODO avoid recreate Album
    album_id = `curl -F album[user_id]=#{user_id} -F album[name]=\"#{name}\" -F album[description]=\"#{description}\" #{address}`

    if album_id =~ /^\d+$/
      return album_id
    else
      return false
    end    
  end
end
