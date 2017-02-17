# chef_node_collection.rb
# Represents a bunch of chef nodes with roles

require 'chef'

class ChefNodeCollection
  def initialize(server_url, client_name, client_key_filename, instance_cost_helper)
    @server_url = server_url
    @client_name = client_name
    @client_key_filename = client_key_filename
    @ich = instance_cost_helper
  end

  def index_roles
    @role_instances = @role_instances || do_index_roles
  end

  protected
  def do_index_roles
    @role_instances = Hash.new

    rest = Chef::REST.new(@server_url, @client_name, @client_key_filename)
    nodes = rest.get_rest("/nodes/")

    nodes.keys.each do |node_name|
      node = rest.get_rest("/nodes/#{node_name}")
      if !node.respond_to?(:run_list) || node.run_list.nil? || node.run_list.to_s.length == 0
        puts "Node #{node_name} had empty run list, skipping"
        next
      end

      if node[:ec2].nil?
        puts "Node #{node_name} has no EC2 attributes, skipping"
        next
      end

      node_role = node.run_list.to_s
      # store the role's product name identifier if defined
      begin
        node_product = node[:crittercism][:tags][:product]
      rescue
        node_product = nil
      end
      node_instance_type = node.ec2.instance_type
      node_az = node.ec2.placement_availability_zone

      role_record = @role_instances[node_role] || Hash.new
      role_instance_record = role_record[node_instance_type] || Hash.new
      riaz = role_instance_record[node_az] || { :count => 0, :cost => 0, :nodes => [] }

      riaz[:count] = riaz[:count] + 1
      riaz[:cost] = riaz[:cost] + @ich.instance_dollars_per_month(node_instance_type, node_az)
      riaz[:nodes] << node_name
      riaz[:product_name] = node_product

      role_instance_record[node_az] = riaz
      role_record[node_instance_type] = role_instance_record
      @role_instances[node_role] = role_record
    end 

    @role_instances
  end
end

