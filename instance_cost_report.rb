# instance_cost_report.rb
# Shows our instance spending by category

class InstanceCostReport
  def initialize(instance_cost_helper)
    @ich = instance_cost_helper
  end

  def write
    puts "instance type,az,count,demand count,ri count,category opex $/mo,category capex $/mo,category $/mo,avg instance opex $/mo,avg instance capex $/mo,avg instance $/mo"
    instance_types = [ "m1.small", "m1.medium", "m1.large", "m1.xlarge",
      "m3.medium", "m3.large", "m3.xlarge", "m3.2xlarge", "t1.micro", "m2.xlarge", "m2.2xlarge",
      "m2.4xlarge", "c1.medium", "c1.xlarge", "c3.large", "c3.xlarge",
      "c3.2xlarge", "r3.large", "r3.xlarge", "r3.2xlarge", "r3.4xlarge", "r3.8xlarge",
      "i2.xlarge", "i2.2xlarge", "i2.4xlarge", "i2.8xlarge" ]
    availability_zones = [ 'us-west-1a', 'us-west-1c' ]

    instance_types.each do |it|
      availability_zones.each do |az|
        category_count = @ich.category_count(it, az)
        next if category_count == 0
        demand_count = @ich.demand_instance_count(it, az)
        ri_count = @ich.reserved_instance_count(it, az)
        codpm = @ich.category_opex_dollars_per_month(it, az)
        ccdpm = @ich.category_capex_dollars_per_month(it, az)
        cdpm  = @ich.category_dollars_per_month(it, az)

        iodpm = @ich.instance_opex_dollars_per_month(it, az)
        icdpm = @ich.instance_capex_dollars_per_month(it, az)
        idpm  = @ich.instance_dollars_per_month(it, az)

        puts "#{it},#{az},#{category_count},#{demand_count},#{ri_count},$#{codpm.round(2)},$#{ccdpm.round(2)},$#{cdpm.round(2)},$#{iodpm.round(2)},$#{icdpm.round(2)},$#{idpm.round(2)}"
      end
    end
  end
end

