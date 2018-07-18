class ProxyIp
  def initialize
    @agent = Mechanize.new
    @api_url = "http://api.ninjasproxy.com/v1/myProxies?apiKey=#{captcha_api_key}&simple=true"
    @username = captcha_username
    @password = captcha_password
    @domain =   'http://www.google.com'
    @check_ip = 'https://api.ipify.org/?format=json'
    @proxy_yaml = 'proxy_file.yaml'
  end

  attr_reader  :agent, :api_url, :username, :password, :check_ip, :domain, :proxy_yaml
  def call
     page = agent.get(api_url).content.to_s
     api_list  = JSON.parse(page)
     proxy_array = Array.new
     api_list.each do |record|
      proxies = {
      host: record['address'].split(":")[0],
      port: record['address'].split(":")[1],
      username: username,
      password: password }
      proxy_array << proxies
     end
     proxy_array = check_proxies(proxy_array)
     create_yaml(proxy_array)
  end

  def check_proxies(proxy_array)
    active_list = Array.new
    proxy_array.each do |record|
      agent.set_proxy(record[:host], record[:port].to_i, record[:username], record[:password])
      page = agent.get(check_ip).content.to_s
      puts "acctual => #{page} | provided => #{record[:host]}" # This is your proxy IP
      begin
        page = agent.get(domain).content.to_s
        active_list << record
      rescue => e
        puts e.to_s
        next
      end
    end
    return active_list
  end

  def create_yaml(active_list)
    file = File.open(proxy_yaml,"w")
    file << active_list.to_yaml
    file.close
  end

  def provide_proxy
    reader = YAML.load_file(proxy_yaml) if reader.nil?
    if (Time.now - File.stat(proxy_yaml).mtime).to_i / 86400.0 > 1
      #yaml refreshment time 1 day
      call
    end
    total_size = reader.length - 1
    random_ip = rand(total_size)
    tmp = reader[total_size]
    mech = Mechanize.new
    mech.set_proxy(tmp[:host], tmp[:port].to_i, tmp[:username], tmp[:password])
    mech.keep_alive = true
    mech.user_agent = 'Linux Mozilla'
    mech.idle_timeout = 4
    mech
  end
end

