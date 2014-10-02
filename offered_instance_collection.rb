# offered_instance_collection.rb

require 'algorithms'
require './offered_instance'

class OfferedInstanceCollection
  def initialize(reservations)
    @offered_instances = Hash.new
    populate_on_demand
    populate_reservations(reservations)
  end
  
  def allocate!(type, az)
    min_opex_instance = @offered_instances[type][az].next!
    @offered_instances[type][az].push(min_opex_instance) if min_opex_instance.offer_type == 'demand'

    min_opex_instance
  end

  protected
  def populate_on_demand
    # Populate heaps for on-demand instances
    on_demand_hourly_prices = {
      "m1.small"    => 0.047,
      "m1.medium"   => 0.095,
      "m1.large"    => 0.190,
      "m1.xlarge"   => 0.379,
      "m3.medium"   => 0.077,
      "m3.large"    => 0.154,
      "m3.xlarge"   => 0.308,
      "m3.2xlarge"  => 0.616,
      "t1.micro"    => 0.025,
      "m2.xlarge"   => 0.275,
      "m2.2xlarge"  => 0.550,
      "m2.4xlarge"  => 1.100,
      "c1.medium"   => 0.148,
      "c1.xlarge"   => 0.592,
      "c3.large"    => 0.120,
      "c3.xlarge"   => 0.239,
      "c3.2xlarge"  => 0.478,
      "r3.large"    => 0.390,
      "r3.xlarge"   => 0.780,
      "r3.2xlarge"  => 0.780,
      "r3.4xlarge"  => 1.560,
      "r3.8xlarge"  => 3.120,
      "i2.xlarge"   => 0.938,
      "i2.2xlarge"  => 1.876,
      "i2.4xlarge"  => 3.751,
      "i2.8xlarge"  => 7.502
    }

    on_demand_hourly_prices.each do |instance_type, on_demand_hourly_price|
      @offered_instances[instance_type] = {
        "us-west-1a" => Containers::MinHeap.new([OfferedInstance.new(
          :opex_dollars_per_hour => on_demand_hourly_price,
          :capex_dollars_per_hour => 0,
          :availability_zone => "us-west-1a",
          :instance_type => instance_type,
          :offer_type => 'demand')]),
        "us-west-1c" => Containers::MinHeap.new([OfferedInstance.new(
          :opex_dollars_per_hour => on_demand_hourly_price,
          :capex_dollars_per_hour => 0,
          :availability_zone => "us-west-1c",
          :instance_type => instance_type,
          :offer_type => 'demand')]),
       }
    end 
  end

  def populate_reservations(reservations)
    reservations.each do |res|
      # Assert hourly pricing, fix if it uses something else
      throw StandardError if res.recurring_charges[0][:frequency] != "Hourly"
      # Duration is in seconds, convert to hours
      capex_dollars_per_hour = (res.fixed_price / res.duration.to_f) * 60 * 60

      res.instance_count.times do
        @offered_instances[res.instance_type][res.availability_zone].push(
          OfferedInstance.new(:opex_dollars_per_hour => res.recurring_charges[0][:amount],
            :capex_dollars_per_hour => capex_dollars_per_hour,
            :availability_zone => res.availability_zone,
            :instance_type => res.instance_type,
            :offer_type => 'reserved'))
      end
    end
  end
end

