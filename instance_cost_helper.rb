# instance_cost_helper.rb
# Computes average cost for a particular instance type, net of all
# reservations and such. Most algorithmically complex piece of this tool.

require './offered_instance_collection'

class InstanceCostHelper
  def initialize(reservations, running_instances)
    @running_instances = running_instances
    @offered_instances = OfferedInstanceCollection.new(reservations)
  end

  def compute_costs
    # memoized
    @dollars_per_month_spending = @dollars_per_month_spending || do_compute_costs
  end

  def category_count(it, az)
    @dollars_per_month_spending[it][az][:instance_count]
  end

  def demand_instance_count(it, az)
    @dollars_per_month_spending[it][az][:demand_instance_count]
  end

  def reserved_instance_count(it, az)
    @dollars_per_month_spending[it][az][:reserved_instance_count]
  end

  def category_opex_dollars_per_month(it, az)
    @dollars_per_month_spending[it][az][:opex_dollars_per_month]
  end

  def category_capex_dollars_per_month(it, az)
    @dollars_per_month_spending[it][az][:capex_dollars_per_month]
  end

  def category_dollars_per_month(it, az)
    category_opex_dollars_per_month(it, az) + category_capex_dollars_per_month(it, az)
  end

  def instance_opex_dollars_per_month(it, az)
    if category_count(it, az) > 0
      category_opex_dollars_per_month(it,az) / category_count(it, az)
    else
      0
    end
  end

  def instance_capex_dollars_per_month(it, az)
    if category_count(it, az) > 0
      category_capex_dollars_per_month(it, az) / category_count(it, az)
    else
      0
    end
  end

  def instance_dollars_per_month(it, az)
    if category_count(it, az) > 0
      category_dollars_per_month(it, az) / category_count(it, az)
    else
      0
    end
  end

  protected
  def do_compute_costs
    instance_types = [ "m1.small", "m1.medium", "m1.large", "m1.xlarge",
      "m3.medium", "m3.xlarge", "m3.2xlarge", "t1.micro", "m2.xlarge", "m2.2xlarge",
      "m2.4xlarge", "c1.medium", "c1.xlarge", "c3.large", "c3.xlarge",
      "c3.2xlarge", "r3.large", "r3.xlarge", "r3.2xlarge", "r3.4xlarge",
      "i2.xlarge", "i2.2xlarge", "i2.4xlarge", "i2.8xlarge" ]
    availability_zones = [ 'us-west-1a', 'us-west-1c', 'us-west-2a', 'us-west-2b', 'us-west-2c' ]

    @dollars_per_month_spending = Hash.new
    instance_types.each do |ins_type|
      @dollars_per_month_spending[ins_type] = Hash.new
      availability_zones.each do |az|
        @dollars_per_month_spending[ins_type][az] = {
          :capex_dollars_per_month => 0,
          :opex_dollars_per_month => 0,
          :instance_count => 0,
          :reserved_instance_count => 0,
          :demand_instance_count => 0
        }
      end
    end

    @running_instances.each do |running_instance|
      rit = running_instance.instance_type
      riaz = running_instance.availability_zone
      oi = @offered_instances.allocate!(rit, riaz)
      spend = @dollars_per_month_spending[rit][riaz]

      spend[:capex_dollars_per_month] = spend[:capex_dollars_per_month] + 
        oi.capex_dollars_per_hour * (24 * 30)
      spend[:opex_dollars_per_month] = spend[:opex_dollars_per_month] +
        oi.opex_dollars_per_hour * (24 * 30)
      spend[:instance_count] = spend[:instance_count] + 1

      case oi.offer_type
      when 'reserved'
        spend[:reserved_instance_count] = spend[:reserved_instance_count] + 1
      when 'demand'
        spend[:demand_instance_count] = spend[:demand_instance_count] + 1
      end

      @dollars_per_month_spending[rit][riaz] = spend
    end

    @dollars_per_month_spending
  end
end
