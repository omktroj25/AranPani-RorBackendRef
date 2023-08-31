# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_08_30_055810) do
  create_table "activities", force: :cascade do |t|
    t.integer "project_id", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_activities_on_project_id"
  end

  create_table "donor_subscription_histories", force: :cascade do |t|
    t.integer "donor_subscription_id"
    t.integer "subscription_id"
    t.datetime "last_paid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["donor_subscription_id"], name: "index_donor_subscription_histories_on_donor_subscription_id"
    t.index ["subscription_id"], name: "index_donor_subscription_histories_on_subscription_id"
  end

  create_table "donor_subscriptions", force: :cascade do |t|
    t.integer "donor_id"
    t.integer "subscription_id"
    t.datetime "last_paid"
    t.boolean "last_updated"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["donor_id"], name: "index_donor_subscriptions_on_donor_id"
    t.index ["subscription_id"], name: "index_donor_subscriptions_on_subscription_id"
  end

  create_table "donor_users", force: :cascade do |t|
    t.string "name"
    t.integer "age"
    t.string "phonenumber"
    t.string "email"
    t.string "guardian_name"
    t.string "country"
    t.string "pincode"
    t.string "address"
    t.integer "gender"
    t.string "id_card"
    t.string "id_card_value"
    t.boolean "is_onboarded"
    t.string "pan"
    t.integer "donor_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["donor_id"], name: "index_donor_users_on_donor_id"
  end

  create_table "donors", force: :cascade do |t|
    t.string "donor_reg_no"
    t.boolean "is_area_representative"
    t.integer "role"
    t.boolean "status"
    t.integer "family_id"
    t.integer "area_representative_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["area_representative_id"], name: "index_donors_on_area_representative_id"
    t.index ["deleted_at"], name: "index_donors_on_deleted_at"
    t.index ["family_id"], name: "index_donors_on_family_id"
  end

  create_table "donors_family_histories", force: :cascade do |t|
    t.integer "donor_id", null: false
    t.integer "family_history_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["donor_id"], name: "index_donors_family_histories_on_donor_id"
    t.index ["family_history_id"], name: "index_donors_family_histories_on_family_history_id"
  end

  create_table "families", force: :cascade do |t|
    t.datetime "last_paid"
    t.integer "count"
    t.integer "subscription_id"
    t.integer "head_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "last_updated"
    t.index ["head_id"], name: "index_families_on_head_id"
    t.index ["subscription_id"], name: "index_families_on_subscription_id"
  end

  create_table "family_histories", force: :cascade do |t|
    t.integer "count"
    t.datetime "last_paid"
    t.integer "donor_id"
    t.integer "subscription_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["donor_id"], name: "index_family_histories_on_donor_id"
    t.index ["subscription_id"], name: "index_family_histories_on_subscription_id"
  end

  create_table "images", force: :cascade do |t|
    t.string "imageable_type", null: false
    t.integer "imageable_id", null: false
    t.string "image_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["imageable_type", "imageable_id"], name: "index_images_on_imageable"
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer "resource_owner_id"
    t.integer "application_id", null: false
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.string "scopes"
    t.string "previous_refresh_token", default: "", null: false
    t.index ["application_id"], name: "index_oauth_access_tokens_on_application_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri"
    t.string "scopes", default: "", null: false
    t.boolean "confidential", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "payments", force: :cascade do |t|
    t.integer "mode"
    t.boolean "is_one_time_payment"
    t.integer "one_time_payment_amount"
    t.datetime "payment_date"
    t.string "transaction_id"
    t.integer "donor_id"
    t.integer "area_representative_id"
    t.integer "family_history_id"
    t.integer "donor_subscription_history_id"
    t.boolean "settled"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["area_representative_id"], name: "index_payments_on_area_representative_id"
    t.index ["donor_id"], name: "index_payments_on_donor_id"
    t.index ["donor_subscription_history_id"], name: "index_payments_on_donor_subscription_history_id"
    t.index ["family_history_id"], name: "index_payments_on_family_history_id"
  end

  create_table "permissions", force: :cascade do |t|
    t.string "scope"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_permissions_on_user_id"
  end

  create_table "project_documents", force: :cascade do |t|
    t.integer "project_id", null: false
    t.string "document_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_project_documents_on_project_id"
  end

  create_table "project_subscribers", force: :cascade do |t|
    t.integer "donor_id", null: false
    t.integer "project_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["donor_id"], name: "index_project_subscribers_on_donor_id"
    t.index ["project_id"], name: "index_project_subscribers_on_project_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "reg_no"
    t.string "temple_name"
    t.string "incharge_name"
    t.string "phonenumber"
    t.string "location"
    t.integer "status"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer "estimated_amount"
    t.integer "expensed_amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sequence_generators", force: :cascade do |t|
    t.string "model"
    t.integer "seq_no"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "subscriptions", force: :cascade do |t|
    t.integer "plan"
    t.string "no_of_months"
    t.integer "amount"
    t.boolean "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "username", default: "", null: false
    t.string "phonenumber", default: "", null: false
    t.boolean "status", default: true, null: false
    t.integer "role", default: 0, null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "activities", "projects"
  add_foreign_key "donor_subscription_histories", "donor_subscriptions"
  add_foreign_key "donor_subscription_histories", "subscriptions"
  add_foreign_key "donor_subscriptions", "donors"
  add_foreign_key "donor_subscriptions", "subscriptions"
  add_foreign_key "donor_users", "donors"
  add_foreign_key "donors", "donors", column: "area_representative_id"
  add_foreign_key "donors", "families"
  add_foreign_key "donors_family_histories", "donors"
  add_foreign_key "donors_family_histories", "family_histories"
  add_foreign_key "families", "donors", column: "head_id"
  add_foreign_key "families", "subscriptions"
  add_foreign_key "family_histories", "donors"
  add_foreign_key "family_histories", "subscriptions"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "payments", "donor_subscription_histories"
  add_foreign_key "payments", "donors"
  add_foreign_key "payments", "donors", column: "area_representative_id"
  add_foreign_key "payments", "family_histories"
  add_foreign_key "permissions", "users"
  add_foreign_key "project_documents", "projects"
  add_foreign_key "project_subscribers", "donors"
  add_foreign_key "project_subscribers", "projects"
end
