oauth-clients
================

A simple to use plugin for sync messages(or images) from your website to SNS website (tsina,tqq,douban etc)。 based on omini-auth。

## 简介

[omini-auth](https://github.com/intridea/omniauth) 是用来获取用户在SNS网站上【授权】的一个Gem， 而oauth-clients就是要干接下来的事情。

接下来你需要:

1. 将第三方网站的credentials保存起来
2. 当用户在你网站上操作时， 他(她)希望在后台自动将这个操作同步到自己的SNS网站上。

## 安装

* rails plugin install git@github.com:charlescui/oauth-clients.git
* rails g oauth_clients:install [oauth_clients.rb]
	默认安装oauth_clients.rb到config/initializers/目录，可以通过更改oauth_clients:install后的参数改变配置文件名称
* 修改配置文件中的key以及secret等为你自己的配置

## 功能

* 支持网站 t.sina,t.qq,  douban, renren
	 如果没有你想要的，你也可以自己去 oauth-clients/lib/clients.rb增加
* 支持附图功能（目前只支持t.sina)

## Example usage

##### 1. Setting up a yml file(config/auth-clients.yml)
  
      OAuthClients::Provider.global_config = {
        "base" => {
          "realm" => "http://www.yourwebsite.com"
        },
        "tsina" => {
          "order" => 1,
          "key" => "your tsina app key",
          "secret" => "your tsina app secret"
        },
        "renren" => {
          "order" => 2,
          "key" => "your renren app key",
          "secret" => "your renren app secret",
          "options" =>
          {
            :scope => 'publish_feed,status_update'
          }
        }
      }

#####2. create a file with the folloing content(config/initializers/oauth-clients-initializer.rb)

		#setting up omini-auth
		OAuthClients::Provider.all.each do |provider|
		  klass = OmniAuth::Strategies.const_get("#{OmniAuth::Utils.camelize(provider.name)}")
		  ActionController::Dispatcher.middleware.use klass, provider.key, provider.secret, provider.options||{}
		end
		
#####3. define a routes to your own omini-auth controller\#action

  config/routes.rb

		map.connect '/auth/:type/callback', :controller => 'session', :action => 'omniauth_callback'

  app/controllers/session_controller.rb

		class SessionController  < ApplicationController
		  def omniauth_callback
		    if auth = request.env['omniauth.auth']
		       auth_info = {:provider    => params[:type],
		                   :credentials => {:token => auth["credentials"]["token"],:secret => auth["credentials"]["secret"],
		                   :user_info   => auth["user_info"] }
		       # save auth_info to database, example:
		       #  User.current.auth_info.create(auth_info)				
		       flash["notice"] = "绑定帐号成功!"
		     else
		       flash["error"] = "绑定帐号失败: 系统错误!"
		     end
		       redirect_to '/profile/third_party_service'
		     end
		  end
		end
		
#####4. Send Messages to 3rd parties(QQ,Douban,tsina etc)

		auth_info = User.current.auth_info	
		client = OAuthClients::Provider[auth_info.provider].client(JSON.parse(auth_info.data))
		client.say('hello','image_url' => YOUR_IMAGE_URL)
		client.friends##返回好友网站ID数组(目前支持tsina[所关注的人,follows])


#####5. Optional: use resque or delyed_job, so that you can put #3 in to background

		class SyncMessageTo3rdPartiesJob < Struct.new(:auth_info_id,:message,:image_url)  
		  def self.create_and_perform(auth_info_id, message,image_url)
		    Delayed::Job.enqueue new(auth_info_id, message,image_url)
		  end    
		  def perform
		    account = AuthInfo.find(auth_info_id)
		    if account.nil?
		      RAILS_DEFAULT_LOGGER.info "account not found id: #{account_id}"
		      return
		    else
		      RAILS_DEFAULT_LOGGER.info "sync to #{account.provider} "
		      resp = account.client.say(message,'image_url' => image_url)
		      RAILS_DEFAULT_LOGGER.info "response: #{resp.body}"
		    end
		  end
		end

Usage:

In your controller:

	SyncMessageTo3rdPartiesJob.create_and_perform(User.current.auth_info, message, image_url)
