require 'optparse'
require 'ostruct'
require 'awesome_print'
require './aws_connection'
require './reserved_instance_report'
require './instance_cost_helper'
require './instance_cost_report'
require './chef_node_collection'
require './role_instance_report'

class AuditorOptionParser
  def self.parse(args)
    options = OpenStruct.new
    options.aws_access_key = nil
    options.aws_secret_key = nil

    optparse = OptionParser.new do |opts|
      opts.banner = "Usage: auditor.rb [options]"
      opts.separator ""
      opts.separator "Specific options:"

      opts.on('-a', '--access-key AWS_ACCESS_KEY', "AWS access key") do |arg|
        options.aws_access_key = arg
      end

      opts.on('-s', '--secret-key AWS_SECRET_KEY', "AWS secret key") do |arg|
        options.aws_secret_key = arg
      end
    end

    optparse.parse!(args)
    options
  end
end

options = AuditorOptionParser.parse(ARGV)

aws_connection = AWSConnection.new(:access_key_id => options.aws_access_key,
  :secret_access_key => options.aws_secret_key)

reservations = aws_connection.get_instance_reservations(:state => 'active')
running_instances = aws_connection.get_instances(:status => :running)

ich = InstanceCostHelper.new(reservations, running_instances)
ich.compute_costs

chef_nodes = ChefNodeCollection.new('https://lechef.crittercism.com/',
  'david', '/home/david/.chef/david.pem', ich)
chef_nodes.index_roles

#rir = ReservedInstanceReport.new(reservations)
#rir.write

#icr = InstanceCostReport.new(ich)
#icr.write

rir = RoleInstanceReport.new(chef_nodes)
rir.write

