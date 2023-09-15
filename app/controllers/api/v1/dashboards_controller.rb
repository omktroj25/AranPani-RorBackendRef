class Api::V1::DashboardsController < ApplicationController
    def dashboard_stats
        project_stats=Project.group('status').count

        donor_stats=Donor.where(is_area_representative:false).group('status').count
        result_donor_stats=stats(donor_stats)
        result_donor_stats["total_donors"]=total_stats(result_donor_stats)

        rep_stats=Donor.where(is_area_representative:true).group('status').count
        result_rep_stats=stats(rep_stats)
        result_rep_stats["total_reps"]=total_stats(result_rep_stats)

        user_stats=User.where(role:User.roles[:user]).group('status').count
        result_user_stats=stats(user_stats)
        result_user_stats["total_users"]=total_stats(result_user_stats)
        
        render json:{project_stats:project_stats,donor_stats:result_donor_stats,rep_stats:result_rep_stats,user_stats:result_user_stats},status: :ok
    end
    def donor_stats
        donor_stats=Donor.group("strftime('%m %Y', created_at)").count
        result=[]
        donor_stats.each do |k,v|
            result.push({"month"=>k,"donors_signed_up"=>v})
        end
        render json:{"donor_stats":result},status: :ok
    end 
    def donation_stats
        result={}
        payment_stats=Payment.where("strftime('%Y', payment_date) = ?",params[:year]).group("strftime('%m', payment_date)","mode","is_one_time_payment").sum('amount')
        payment_stats.each do |k,v|
            if !result.has_key?(k[0])
                result[k[0]]={"online_payment"=>0,"offline_payment"=>0,"one_time_payment"=>0,"total_payment"=>0}
            end
            if k[1]=='offline'
                result[k[0]]['offline_payment']+=v
            else
                result[k[0]]['online_payment']+=v
            end
            if k[2]
                result[k[0]]["one_time_payment"]+=v
            end
            result[k[0]]['total_payment']+=v
        end
        render json:{donation_stats:result},status: :ok
            
    end
    private
    def stats(donor_stats)
        {'Active'=>donor_stats.has_key?(true) ? donor_stats[true]:0,'InActive'=>donor_stats.has_key?(false) ? donor_stats[false]:0}
    end
    def total_stats(stats)
        stats["Active"]+stats["InActive"]
    end
end
