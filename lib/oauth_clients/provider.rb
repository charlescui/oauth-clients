module OAuthClients
  class Provider
    def self.global_config= (config)
      @global_config = config.to_options
      @all = nil
    end
    
    def self.global_config
      if @global_config.nil?
        raise 'OAuthClients::Provider.global_config = {YOUR_CONFIG_HASH} first!'
      end
      @global_config
    end
    
    def self.all
      @all||=global_config.except(:base).map{|k,v| self.new(k,global_config[:base].merge(v).to_options)}.sort        
    end
  
    def self.[](key)
      all.find{|e|e.name == key.to_sym}
    end
  
    attr_accessor :name,:config
  
    def initialize(k,v)
      @name = k
      @config = v
    end
    
    def key
      @config[:key]
    end
    
    def secret
      @config[:secret]
    end
    
    def options
      @config[:options]
    end
    
    def order
      @config[:order]||0
    end
    
    def client(credentials)
      @client = "OAuthClients::Clients::#{self.name.capitalize}".constantize.new(self,credentials.to_options)
    end
    
    def <=>(other)
      self.order <=> other.order
    end
  end
  
end
