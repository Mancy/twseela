require 'rest_client'

class Graphdb
  @@neo4j_url = GRAPH_DB_CONFIG[:server]
  
  # Graphdb.create_index()
  # Graphdb.create_index("relationship")
  
  def self.create_index(index_for = "node")
    index_found = false
    begin
      RestClient.get("#{GRAPH_DB_CONFIG[:server]}/index/#{index_for}/users_#{index_for}s")
      index_found = true
    rescue
    end
    if index_found == false 
      data = {:name => "users_#{index_for}s", :config => {:type => "exact", :provider => "lucene"}}
      res = RestClient.post URI.encode("#{@@neo4j_url}/index/#{index_for}"), ActiveSupport::JSON.encode(data) , :content_type => :json
    end
  end
  
  def self.friends_list(account)
    rel_types = []
    rel_types << "friend"
    rel_types << "follower" if account.provider == "twitter" && account.user.trust_level == 3
    
    unless account.node_id.blank?
      Graphdb.traverse_node(account.node_id, rel_types, account.user.trust_level)
    else
      inputs = []
      inputs << {:provider => account.provider, :uid => account.uid}
      res = Graphdb.batch_finds(inputs)
      if !res[account.uid].blank? && !res[account.uid]["id"].blank?
        account.update_attribute(:node_id, res[account.uid]["id"])
        Graphdb.traverse_node(res[account.uid]["id"], rel_types, account.user.trust_level)
      end
    end
  end
  
  def self.update_friends_list(account, friends, rel_type)
    inputs = []
    
    find_inputs = []
    rel_find_inputs = []
    
    results = {}
    rel_results = {}
    
    account_node = nil
    
    find_inputs << {:provider => account.provider , :uid => account.uid}
    friends.each do |friend|
      find_inputs << {:provider => account.provider , :uid => friend}
      
      rel_name = Graphdb.rel_name(account.uid.to_s, friend.to_s, account.provider)
      rel_find_inputs << {:name => rel_name}
    end
    results = Graphdb.batch_finds(find_inputs)
    rel_results = Graphdb.rel_batch_finds(rel_find_inputs)
    
    if results[account.uid].blank?
      inputs << {:type => :insert, :attrs => {:uid => account.uid, :user_id => account.user_id, :provider => account.provider, :account_id => account.id}}
      account_node = "{0}"
    else
      inputs << {:type => :update, :id => results[account.uid]['id'], :attrs => {:uid => account.uid, :user_id => account.user_id, :provider => account.provider, :account_id => account.id}}
      account_node = "/node/#{results[account.uid]['id']}"
    end
    
    friends.each_with_index do |friend, index|
      rel_name = Graphdb.rel_name(account.uid.to_s, friend.to_s, account.provider)
      unless results[friend].blank? # exists
        if rel_results[rel_name] != true
          inputs << {:type => :relationship, :from_node => account_node, :to_node => "/node/#{results[friend]['id']}", :name => rel_name, :rel_type => rel_type}
        end
      else # not exists
        inputs << {:type => :insert, :attrs => {:uid => friend, :user_id => "", :provider => account.provider, :account_id => "0"}}
        inputs << {:type => :relationship, :from_node => account_node, :to_node => "{#{inputs.size-1}}", :name => rel_name, :rel_type => rel_type}
      end
    end
    output = Graphdb.batch_operations(inputs)
    #puts " > > > > > output : #{output}"
    output
  end
  
  # inputs = []
  
  # when :insert
  # inputs << {:type => :insert, :attrs => {:uid => "45456465464", :user_id => "2", :provider => "facebook", :account_id => "1"}}
  # inputs << {:type => :insert, :attrs => {:uid => "45456465461", :user_id => "2", :provider => "facebook", :account_id => "1"}}
  
  # when :relationship
  # inputs << {:type => :relationship, :from_node => "{0}", :to_node => "/node/NODEID", :name => "NAME HERE", :rel_type => "Rel Type"}
  # inputs << {:type => :relationship, :from_node => "/node/NODEID", :to_node => "{1}", :name => "NAME HERE", :rel_type => "Rel Type"}
  
  #when :delete_node
  # inputs << {:type => :delete_node, :id => "2"}
  
  # when :delete_relationship
  # inputs << {:type => :delete_relationship, :id => "16"}
  
  # when :update
  # inputs << {:type => :update, :id => "16", :attrs => {:uid => "45456465464", :user_id => "2", :provider => "facebook", :account_id => "1"}}
  
  
  def self.batch_operations(inputs)
    operations=[]
    
    inputs.each_with_index do |input,index|
      case input[:type]
      when :insert
        operations << {:method => "POST", :to => "/node", :body => input[:attrs], :id => index}
        i = {:key => "uid",  :uri => "{#{index}}", :value => "#{input[:attrs][:provider]}_#{input[:attrs][:uid]}"}
        operations << {:method => "POST", :to => "/index/node/users_nodes", :body => i}
      when :update
        operations << {:method => "PUT", :to => "/node/#{input[:id]}/properties", :body => input[:attrs], :id => index}
      when :relationship
        operations << {:method => "POST", :to => "#{input[:from_node]}/relationships", :body => {:to => "#{input[:to_node]}", :type => input[:rel_type]}, :id => index}
        i = {:key => "rel_name",  :uri => "{#{index}}", :value => input[:name]}
        operations << {:method => "POST", :to => "/index/relationship/users_relationships", :body => i}
      when :delete_relationship
        operations << {:method => "DELETE", :to => "/relationship/#{input[:id]}", :id => index}
        #todo 
        #delete index
      when :delete_node
        operations << {:method => "DELETE", :to => "/node/#{input[:id]}", :id => index.to_s}
        #todo 
        #delete index
      end
    end
    
    if operations.size > 0
      
      # if (operations.size > 1000)
      #   new_size = (operations.size / 1000) + 1
      #   small_operations = chunk_array(operations, new_size)
      # end
      # small_operations ||= [operations]
      # 
      # small_operations.each do |small_operation|
      #   response = RestClient.post("#{@@neo4j_url}/batch", ActiveSupport::JSON.encode(small_operation) , :content_type => :json)
      #   raise Exception.new(response.body) if response.code != 200
      # end
      
      begin
        puts " > > > start : #{operations.size}"
        response = RestClient.post("#{@@neo4j_url}/batch", ActiveSupport::JSON.encode(operations) , :content_type => :json)
        puts " > > > stop "
      rescue => e 
        puts " > > > e.message : #{e.message}"
        puts " > > > e.message : #{e.inspect}"
      end
      
      raise Exception.new(response.body) if response.code != 200
      response.body
    end
  end
  
  # inputs = []
  # inputs << {:provider => "facebook", :uid => "111"}
  
  def self.batch_finds(inputs)
    results={}
    operations =[]
    
    inputs.each_with_index do |input, index|
      url = URI.encode("/index/node/users_nodes/uid/#{input[:provider]}_#{input[:uid]}")
      operations << {:method => "GET", :to => url, :id => index}
    end
    begin
      response = RestClient.post "#{@@neo4j_url}/batch", ActiveSupport::JSON.encode(operations) , :content_type => :json
      
      JSON.parse(response).each_with_index do |res, index|
        unless res["body"].blank? 
          id = res["body"].first["indexed"].split("/").last
          data = res["body"].first["data"]  
          data["id"] = id  
          results[data["uid"]] = data 
        end
      end
    rescue
      
    end
    
    results
  end
  
  # inputs = []
  # inputs << {:name => "272_facebook_273"}
  
  def self.rel_batch_finds(inputs)
    results={}
    operations =[]
    
    inputs.each_with_index do |input, index|
      url = URI.encode("/index/relationship/users_relationships/rel_name/#{input[:name]}")
      operations << {:method => "GET", :to => url, :id => index}
    end
    
    response = RestClient.post "#{@@neo4j_url}/batch", ActiveSupport::JSON.encode(operations) , :content_type => :json
    
    JSON.parse(response).each_with_index do |res, index|
      from_rel = res["from"].split("/").last
      unless res["body"].blank?
        results[from_rel] = true
      else
        results[from_rel] = false
      end
    end
    results
  end
  
  def self.traverse_node(node_id, rel_types = [], depth = 1)
    uids = []
    relationships_types = []
    
    rel_types.each do |rel_type|
      relationships_types << {:direction => "all", :type => rel_type}
    end
    
    traverse_query= {:order => "breadth_first",
                     :prune_evaluator => {:name => "none", :language => "builtin"},
                     :uniqueness =>  "node_global",
                     :relationships => relationships_types,
                     # :prune_evaluator => {
                     #    :body => "position.length() >= 1",
                     #    :language => "javascript"
                     #  },
                     :max_depth => depth}
                     
    begin
      response = RestClient.post "#{@@neo4j_url}/node/#{node_id}/traverse/node", ActiveSupport::JSON.encode(traverse_query) , :content_type => :json
      
      JSON.parse(response).each do |res|
        unless res["data"].blank?
          uids << res["data"]["uid"]
        end
      end
    rescue
    end
    uids
  end
  
  def self.rel_name(from, to, provider)
    from >= to ? "#{to}_#{provider}_#{from}" : "#{from}_#{provider}_#{to}"
  end
  
  def chunk_array(array, pieces=2)
    len = array.length;
    mid = (len/pieces)
    chunks = []
    start = 0
    1.upto(pieces) do |i|
      last = start+mid
      last = last-1 unless len%pieces >= i
      chunks << array[start..last] || []
      start = last+1
    end
    chunks
  end

end