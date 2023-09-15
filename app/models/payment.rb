class Payment < ApplicationRecord
    enum mode: [:online,:offline]
    belongs_to :donor
    belongs_to :area_representative,class_name: 'Donor',foreign_key: :area_representative_id,primary_key: 'area_representative_id',optional:true
    belongs_to :family_history,optional:true
    belongs_to :subscription,optional:true
    before_save :add_payment_date

    scope :search,->(params){where(["strftime('%m', payment_date) = ? and strftime('%Y', payment_date) = ?", "#{Date::ABBR_MONTHNAMES.index(params[:month]).to_s.rjust(2,'0')}","#{params[:year]}"]).paginate(page:params[:page],per_page:params[:limit])}
    scope :group_by_mode,->(params){where(["strftime('%m', payment_date) = ? and strftime('%Y', payment_date) = ?", "#{Date::ABBR_MONTHNAMES.index(params[:month]).to_s.rjust(2,'0')}","#{params[:year]}"]).group("mode").sum("amount")}
    scope :group_by_settlement,->(params){where(["strftime('%m', payment_date) = ? and strftime('%Y', payment_date) = ?", "#{Date::ABBR_MONTHNAMES.index(params[:month]).to_s.rjust(2,'0')}","#{params[:year]}"]).group("settled").sum("amount")}
    scope :one_time_payment_search,->(params){where(["strftime('%m', payment_date) = ? and strftime('%Y', payment_date) = ? and is_one_time_payment=?", "#{Date::ABBR_MONTHNAMES.index(params[:month]).to_s.rjust(2,'0')}","#{params[:year]}",params[:is_one_time_payment] == "true" ? true : false]).paginate(page:params[:page],per_page:params[:limit])}
    
    def add_payment_date
        self.payment_date=Time.now
    end
end
