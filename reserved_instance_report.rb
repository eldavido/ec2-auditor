# reserved_instance_report.rb
# Shows our reserved instance spend

class ReservedInstanceReport
  def initialize(reservations)
    @ris = reservations
  end

  def write
    puts "id,duration,end,qty,type,AZ,capex $/(instance*mo),opex $/(instance*month),"

    @ris.each do |res|
      end_date = res.start + res.duration

      dollars_per_instance_second_capex = res.fixed_price / (res.duration.to_f)
      dollars_per_instance_month_capex  = dollars_per_instance_second_capex * (24 * 30 * 60 * 60)

      throw StandardError if res.recurring_charges[0][:frequency] != "Hourly"
      dollars_per_instance_month_opex = res.recurring_charges[0][:amount] * (24 * 30)

      duration_years = res.duration / 365 / 24 / 60 / 60

      puts "#{res.id},#{duration_years} yr,#{end_date.strftime("%Y/%m/%d")},#{res.instance_count},#{res.instance_type},#{res.availability_zone},$#{dollars_per_instance_month_capex.round(2)},$#{dollars_per_instance_month_opex.round(2)},"
    end
  end
end

