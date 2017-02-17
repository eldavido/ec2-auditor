# role_instance_report.rb
# Reports instance use by role, and costs

class RoleInstanceReport
  def initialize(chef_nodes)
    @chef_nodes = chef_nodes.index_roles
  end

  def write
    puts "role,product,instance type,az,qty,$/(instance*month),$/month"
    @chef_nodes.each do |role_name, role_record|
      role_record.each do |instance_name, instance_record|
        instance_record.each do |az_name, az_record|
          puts "#{role_name},#{az_record[:product_name]},#{instance_name},#{az_name},#{az_record[:count]},$#{(az_record[:cost]/az_record[:count]).round(2)},$#{az_record[:cost].round(2)}"
          #puts "  instances: #{az_record[:nodes].join(",")}"
        end
      end
    end
  end
end
