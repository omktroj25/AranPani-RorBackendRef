# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
if Doorkeeper::Application.count.zero?
    Doorkeeper::Application.create(name: "Web client", redirect_uri: "", scopes: "")
    Doorkeeper::Application.create(name: "Android client", redirect_uri: "", scopes: "")
    Doorkeeper::Application.create(name: "iOS client", redirect_uri: "", scopes: "")
end
if User.count == 0
    User.create(email:"ranjithvel2001@gmail.com",password:"123456789",username:"ranjith",phonenumber:"9842840700",status:true,role:User.roles[:admin])
end
Subscription.find_or_create_by(plan:Subscription.plans[:Monthly],amount:100,no_of_months:"1 month",status:true)
Subscription.find_or_create_by(plan:Subscription.plans[:Quarterly],amount:300,no_of_months:"3 months",status:true)
Subscription.find_or_create_by(plan:Subscription.plans[:HalfYearly],amount:600,no_of_months:"6 months",status:true)
Subscription.find_or_create_by(plan:Subscription.plans[:Yearly],amount:1200,no_of_months:"12 months",status:true)

SequenceGenerator.find_or_create_by(model:"donor",seq_no:1111)
SequenceGenerator.find_or_create_by(model:"project",seq_no:2222)



