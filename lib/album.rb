#
# 远程相册管理
#

require 'rubygems'
require 'rest_client'

class Album
  
  # 静态方法
  # 创建相册
  def self.create(address, user_id, name, description)
    `curl -F album[user_id]=#{user_id} -F album[name]=\"#{name}\" -F album[description]=\"#{description}\" #{address}`
    #RestClient.post(address,:album=>{:user_id=>user_id, :name=>name, :description=>description})
  end
end
