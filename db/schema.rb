# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20160218120848) do

  create_table "active_admin_comments", :force => true do |t|
    t.string   "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "activities", :force => true do |t|
    t.integer  "trackable_id"
    t.string   "trackable_type"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "key"
    t.text     "parameters"
    t.integer  "recipient_id"
    t.string   "recipient_type"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "activities", ["owner_id", "owner_type"], :name => "index_activities_on_owner_id_and_owner_type"
  add_index "activities", ["recipient_id", "recipient_type"], :name => "index_activities_on_recipient_id_and_recipient_type"
  add_index "activities", ["trackable_id", "trackable_type"], :name => "index_activities_on_trackable_id_and_trackable_type"

  create_table "admin_users", :force => true do |t|
    t.string   "email",                                                     :default => "",  :null => false
    t.string   "encrypted_password",                                        :default => "",  :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                             :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                                                 :null => false
    t.datetime "updated_at",                                                                 :null => false
    t.decimal  "balance",                     :precision => 8, :scale => 2, :default => 0.0
    t.string   "balanced_uri"
    t.integer  "default_account"
    t.integer  "default_backup_account"
    t.string   "default_account_type"
    t.string   "default_backup_account_type"
    t.string   "first_name"
    t.string   "last_name"
  end

  add_index "admin_users", ["email"], :name => "index_admin_users_on_email", :unique => true
  add_index "admin_users", ["reset_password_token"], :name => "index_admin_users_on_reset_password_token", :unique => true

  create_table "agentships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "agent_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "agentships", ["agent_id"], :name => "index_agentships_on_agent_id"
  add_index "agentships", ["user_id"], :name => "index_agentships_on_user_id"

  create_table "attends", :force => true do |t|
    t.integer  "attendable_id"
    t.string   "attendable_type"
    t.integer  "user_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "attends", ["user_id", "attendable_id"], :name => "index_attends_on_user_id_and_attendable_id"

  create_table "authorizations", :force => true do |t|
    t.string   "provider"
    t.integer  "uid"
    t.integer  "user_id"
    t.integer  "client_id"
    t.integer  "filmmaker_id"
    t.string   "confirmation_token"
    t.string   "name"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "bank_account_verifications", :force => true do |t|
    t.integer  "bank_account_id"
    t.integer  "attempts"
    t.integer  "attempts_remaining"
    t.string   "balanced_created_at"
    t.string   "deposit_status"
    t.string   "href"
    t.string   "balanced_id"
    t.string   "link_bank_account"
    t.string   "balanced_updated_at"
    t.string   "verification_status"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "bank_accounts", :force => true do |t|
    t.string   "bank_account_uri"
    t.string   "bank_name"
    t.integer  "bank_accountable_id"
    t.string   "bank_accountable_type"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.string   "verification_status"
  end

  create_table "blog_comments", :force => true do |t|
    t.string   "title"
    t.text     "comment"
    t.integer  "user_id"
    t.integer  "post_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "blogs", :force => true do |t|
    t.text     "content"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "blogs", ["user_id"], :name => "index_blogs_on_user_id"

  create_table "characteristics", :force => true do |t|
    t.string   "age"
    t.string   "height"
    t.string   "ethnicity"
    t.string   "bodytype"
    t.string   "hair_color"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "language"
  end

  create_table "ckeditor_assets", :force => true do |t|
    t.string   "data_file_name",                  :null => false
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.integer  "assetable_id"
    t.string   "assetable_type",    :limit => 30
    t.string   "type",              :limit => 30
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "ckeditor_assets", ["assetable_type", "assetable_id"], :name => "idx_ckeditor_assetable"
  add_index "ckeditor_assets", ["assetable_type", "type", "assetable_id"], :name => "idx_ckeditor_assetable_type"

  create_table "clients", :force => true do |t|
    t.string   "name",                                                      :default => "",  :null => false
    t.string   "email",                                                     :default => "",  :null => false
    t.string   "encrypted_password",                                        :default => "",  :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                             :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at",                                                                 :null => false
    t.datetime "updated_at",                                                                 :null => false
    t.boolean  "verified"
    t.boolean  "verified_by_admin"
    t.string   "role"
    t.string   "location"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "provider"
    t.string   "uid"
    t.string   "oauth_token"
    t.datetime "oauth_expires_at"
    t.string   "fb_token"
    t.string   "linkedin_token"
    t.string   "balanced_uri"
    t.integer  "default_account"
    t.integer  "default_backup_account"
    t.decimal  "balance",                     :precision => 8, :scale => 2, :default => 0.0
    t.string   "default_account_type"
    t.string   "default_backup_account_type"
  end

  add_index "clients", ["email"], :name => "index_clients_on_email", :unique => true
  add_index "clients", ["reset_password_token"], :name => "index_clients_on_reset_password_token", :unique => true

  create_table "comments", :force => true do |t|
    t.text     "content"
    t.integer  "user_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.string   "title"
    t.text     "comment"
  end

  add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "conversations", :force => true do |t|
    t.string   "subject",    :default => ""
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  create_table "credit_cards", :force => true do |t|
    t.string   "credit_card_uri"
    t.boolean  "is_authenticated"
    t.string   "card_type"
    t.integer  "card_accountable_id"
    t.string   "card_accountable_type"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0, :null => false
    t.integer  "attempts",   :default => 0, :null => false
    t.text     "handler",                   :null => false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "deposits", :force => true do |t|
    t.integer  "depositable_id"
    t.string   "depositable_type"
    t.decimal  "amount",                  :precision => 8, :scale => 2
    t.text     "appears_on_statement_as"
    t.string   "balanced_created_at"
    t.string   "currency"
    t.text     "description"
    t.text     "failure_reason"
    t.string   "failure_reason_code"
    t.string   "href"
    t.string   "balanced_id"
    t.string   "status"
    t.string   "transaction_number"
    t.string   "balanced_updated_at"
    t.datetime "created_at",                                                               :null => false
    t.datetime "updated_at",                                                               :null => false
    t.string   "link_card_hold"
    t.string   "link_customer"
    t.string   "link_dispute"
    t.string   "link_order"
    t.string   "link_source"
    t.boolean  "pro",                                                   :default => false
  end

  add_index "deposits", ["depositable_id", "depositable_type"], :name => "index_deposits_on_depositable_id_and_depositable_type"

  create_table "direct_hire_proposal_milestones", :force => true do |t|
    t.string   "name"
    t.date     "delivery_date"
    t.float    "amount"
    t.integer  "direct_hire_proposal_id"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.boolean  "is_complete",             :default => false
    t.boolean  "payment_released",        :default => false
    t.boolean  "fund_escrowed",           :default => false
    t.datetime "escrowed_at"
    t.float    "pay_amount",              :default => 0.0
  end

  create_table "direct_hire_proposals", :force => true do |t|
    t.text     "cover_letter"
    t.date     "desired_start_date"
    t.date     "desired_end_date"
    t.boolean  "is_declined"
    t.boolean  "is_approved"
    t.integer  "filmmaker_id"
    t.integer  "client_id"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.integer  "conversation_id"
    t.integer  "project_id"
    t.boolean  "is_modified",        :default => false
  end

  create_table "direct_hires", :force => true do |t|
    t.integer  "filmmaker_id"
    t.integer  "client_id"
    t.integer  "direct_hire_proposal_id"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  create_table "dispute_attachments", :force => true do |t|
    t.string   "attachment"
    t.integer  "dispute_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "disputes", :force => true do |t|
    t.integer  "proposal_id"
    t.string   "dispute_description"
    t.date     "dispute_date"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.string   "status"
  end

  create_table "endorsements", :force => true do |t|
    t.integer  "receiver_id"
    t.integer  "sender_id"
    t.text     "message"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "expertise"
  end

  add_index "endorsements", ["receiver_id", "sender_id"], :name => "index_endorsements_on_receiver_id_and_sender_id"

  create_table "events", :force => true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.text     "description"
    t.string   "website"
    t.string   "location"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "url_name"
  end

  add_index "events", ["user_id"], :name => "index_events_on_user_id"

  create_table "filmmaker_feedbacks", :force => true do |t|
    t.string   "attribute_key"
    t.string   "attribute_value"
    t.integer  "rating"
    t.text     "comment"
    t.integer  "filmmaker_id"
    t.integer  "project_id"
    t.integer  "client_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "filmmakers", :force => true do |t|
    t.string   "name",                                                      :default => "",    :null => false
    t.string   "email",                                                     :default => "",    :null => false
    t.string   "encrypted_password",                                        :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                             :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at",                                                                   :null => false
    t.datetime "updated_at",                                                                   :null => false
    t.boolean  "verified"
    t.boolean  "verified_by_admin"
    t.string   "provider"
    t.string   "uid"
    t.string   "role"
    t.text     "about"
    t.string   "location"
    t.float    "latitude"
    t.float    "longitude"
    t.text     "skills"
    t.string   "oauth_token"
    t.datetime "oauth_expires_at"
    t.string   "fb_token"
    t.string   "linkedin_token"
    t.string   "balanced_uri"
    t.integer  "rate"
    t.boolean  "is_company",                                                :default => false
    t.string   "company"
    t.integer  "default_account"
    t.integer  "default_backup_account"
    t.decimal  "balance",                     :precision => 8, :scale => 2, :default => 0.0
    t.string   "default_account_type"
    t.string   "default_backup_account_type"
  end

  add_index "filmmakers", ["email"], :name => "index_filmmakers_on_email", :unique => true
  add_index "filmmakers", ["reset_password_token"], :name => "index_filmmakers_on_reset_password_token", :unique => true

  create_table "friendships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "friendships", ["friend_id"], :name => "index_friendships_on_friend_id"
  add_index "friendships", ["user_id"], :name => "index_friendships_on_user_id"

  create_table "important_dates", :force => true do |t|
    t.integer  "important_dateable_id"
    t.string   "important_dateable_type"
    t.string   "description"
    t.string   "date_time"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.boolean  "is_start_date",           :default => false
    t.boolean  "is_end_date",             :default => false
    t.string   "date"
    t.string   "time_string"
  end

  add_index "important_dates", ["important_dateable_id"], :name => "index_important_dates_on_important_dateable_id"

  create_table "likes", :force => true do |t|
    t.integer  "user_id"
    t.integer  "loveable_id"
    t.string   "loveable_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "milestones", :force => true do |t|
    t.string   "title"
    t.string   "description"
    t.date     "startdate"
    t.date     "enddate"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "monologue_blogcomments", :force => true do |t|
    t.text     "comment"
    t.integer  "post_id"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.boolean  "is_active",  :default => false
    t.string   "user_name"
    t.string   "user_email"
  end

  create_table "monologue_posts", :force => true do |t|
    t.integer  "posts_revision_id"
    t.boolean  "published"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "image"
  end

  create_table "monologue_posts_revisions", :force => true do |t|
    t.string   "title"
    t.text     "content"
    t.string   "url"
    t.integer  "user_id"
    t.integer  "post_id"
    t.datetime "published_at"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "monologue_posts_revisions", ["id"], :name => "index_monologue_posts_revisions_on_id", :unique => true
  add_index "monologue_posts_revisions", ["post_id"], :name => "index_monologue_posts_revisions_on_post_id"
  add_index "monologue_posts_revisions", ["published_at"], :name => "index_monologue_posts_revisions_on_published_at"
  add_index "monologue_posts_revisions", ["url"], :name => "index_monologue_posts_revisions_on_url"

  create_table "monologue_users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "notifications", :force => true do |t|
    t.string   "type"
    t.text     "body"
    t.string   "subject",              :default => ""
    t.integer  "sender_id"
    t.string   "sender_type"
    t.integer  "conversation_id"
    t.boolean  "draft",                :default => false
    t.datetime "updated_at",                              :null => false
    t.datetime "created_at",                              :null => false
    t.integer  "notified_object_id"
    t.string   "notified_object_type"
    t.string   "notification_code"
    t.string   "attachment"
  end

  add_index "notifications", ["conversation_id"], :name => "index_notifications_on_conversation_id"

  create_table "photos", :force => true do |t|
    t.string   "image"
    t.text     "description"
    t.string   "content_type"
    t.integer  "file_size"
    t.datetime "updated_at",                         :null => false
    t.integer  "imageable_id"
    t.string   "imageable_type"
    t.datetime "created_at",                         :null => false
    t.boolean  "primary"
    t.boolean  "is_main",         :default => false
    t.boolean  "is_cover",        :default => false
    t.integer  "crop_x"
    t.integer  "crop_y"
    t.integer  "crop_w"
    t.integer  "crop_h"
    t.integer  "original_width"
    t.integer  "original_height"
  end

  create_table "pro_accounts", :force => true do |t|
    t.string   "account_type"
    t.datetime "payment_at"
    t.integer  "accountable_id"
    t.string   "accountable_type"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "profiles", :force => true do |t|
    t.string   "image"
    t.string   "description"
    t.string   "content_type"
    t.integer  "file_size"
    t.datetime "updated_at",      :null => false
    t.integer  "user_id"
    t.datetime "created_at",      :null => false
    t.integer  "crop_x"
    t.integer  "crop_y"
    t.integer  "crop_w"
    t.integer  "crop_h"
    t.integer  "original_width"
    t.integer  "original_height"
    t.integer  "filmmaker_id"
    t.integer  "client_id"
  end

  create_table "project_attachments", :force => true do |t|
    t.integer  "project_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "attachment"
  end

  create_table "project_blacklists", :force => true do |t|
    t.integer  "project_id"
    t.integer  "filmmaker_id"
    t.datetime "blocked_at"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "project_direct_hires", :force => true do |t|
    t.integer  "filmmaker_id"
    t.integer  "client_id"
    t.integer  "direct_hire_proposal_id"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  create_table "project_feedbacks", :force => true do |t|
    t.integer  "client_id"
    t.integer  "filmmaker_id"
    t.integer  "project_id"
    t.integer  "cost"
    t.integer  "response"
    t.integer  "expertise"
    t.integer  "schedule"
    t.integer  "professional"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.string   "comment"
    t.integer  "total_rating", :default => 0
  end

  create_table "project_hires", :force => true do |t|
    t.integer  "filmmaker_id"
    t.integer  "client_id"
    t.integer  "proposal_id"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.integer  "proposal_revision_id"
  end

  create_table "project_proposal_milestones", :force => true do |t|
    t.string   "name"
    t.date     "delivery_date"
    t.float    "amount"
    t.integer  "project_proposal_id"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.boolean  "is_complete",         :default => false
    t.boolean  "payment_released",    :default => false
    t.boolean  "fund_escrowed",       :default => false
    t.datetime "escrowed_at"
    t.float    "pay_amount",          :default => 0.0
  end

  create_table "project_proposals", :force => true do |t|
    t.text     "cover_letter"
    t.date     "desired_start_date"
    t.date     "desired_end_date"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.integer  "project_id"
    t.integer  "filmmaker_id"
    t.boolean  "is_declined",        :default => false
    t.boolean  "is_approved",        :default => false
    t.integer  "approved_by"
    t.boolean  "is_delete",          :default => false
    t.integer  "conversation_id"
    t.boolean  "is_modified",        :default => false
  end

  create_table "project_questions", :force => true do |t|
    t.string   "question_text", :null => false
    t.string   "answer_text",   :null => false
    t.integer  "project_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "projects", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "user_id"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.string   "status"
    t.boolean  "featured"
    t.string   "location"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "thoughts"
    t.string   "compensation"
    t.text     "headline"
    t.string   "union"
    t.string   "url_name"
    t.boolean  "union_present",           :default => false
    t.string   "skills"
    t.float    "price"
    t.string   "ip_address"
    t.boolean  "is_featured",             :default => false
    t.boolean  "featured_payment_status", :default => false
  end

  create_table "proposal_resumes", :force => true do |t|
    t.string   "attachment"
    t.integer  "project_proposal_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "proposal_revisions", :force => true do |t|
    t.integer  "project_proposal_id"
    t.integer  "revised_by"
    t.string   "revised_user_type"
    t.integer  "revision_count"
    t.text     "description"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "receipts", :force => true do |t|
    t.integer  "receiver_id"
    t.string   "receiver_type"
    t.integer  "notification_id",                                  :null => false
    t.boolean  "is_read",                       :default => false
    t.boolean  "trashed",                       :default => false
    t.boolean  "deleted",                       :default => false
    t.string   "mailbox_type",    :limit => 25
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
  end

  add_index "receipts", ["notification_id"], :name => "index_receipts_on_notification_id"

  create_table "role_applications", :force => true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.text     "message"
    t.boolean  "approved",   :default => false
    t.boolean  "manager",    :default => false
  end

  add_index "role_applications", ["user_id", "role_id"], :name => "index_role_applications_on_user_id_and_role_id"

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "project_id"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.boolean  "filled",        :default => false
    t.string   "subrole"
    t.string   "gender",        :default => "male"
    t.string   "super_subrole"
    t.string   "age"
    t.string   "ethnicity"
    t.string   "height"
    t.string   "build"
    t.string   "haircolor"
    t.string   "cast_title"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       :limit => 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "talents", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "user_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.text     "synopsis"
    t.string   "sub_talent"
    t.string   "super_sub_talent"
  end

  create_table "temporary_data", :force => true do |t|
    t.text     "data"
    t.datetime "expires_at"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "updated_project_proposal_milestones", :force => true do |t|
    t.integer  "project_proposal_id"
    t.string   "name"
    t.date     "delivery_date"
    t.float    "amount"
    t.boolean  "fund_escrowed",        :default => false
    t.boolean  "payment_released",     :default => false
    t.boolean  "is_complete",          :default => false
    t.float    "pay_amount",           :default => 0.0
    t.datetime "escrowed_at"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.integer  "revision_count"
    t.integer  "proposal_revision_id"
  end

  create_table "uploaded_documents", :force => true do |t|
    t.string   "document"
    t.string   "description"
    t.string   "content_type"
    t.integer  "file_size"
    t.datetime "updated_at",        :null => false
    t.integer  "documentable_id"
    t.string   "documentable_type"
    t.datetime "created_at",        :null => false
    t.string   "filename"
  end

  create_table "urls", :force => true do |t|
    t.string   "url"
    t.integer  "urlable_id"
    t.string   "urlable_type"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "location"
    t.float    "latitude"
    t.float    "longitude"
    t.text     "about"
    t.boolean  "superadmin"
    t.boolean  "admin"
    t.boolean  "editor"
    t.string   "provider"
    t.string   "uid"
    t.string   "oauth_token"
    t.datetime "oauth_expires_at"
    t.datetime "created_at",                                                 :null => false
    t.datetime "updated_at",                                                 :null => false
    t.string   "gender"
    t.string   "imdb_url"
    t.text     "headline"
    t.boolean  "featured"
    t.string   "expertise"
    t.datetime "notification_check_time", :default => '2016-02-11 12:57:05'
    t.string   "experience"
    t.boolean  "agent_present",           :default => false
    t.string   "agent_name"
    t.string   "guild"
    t.boolean  "guild_present",           :default => false
    t.string   "url_name"
    t.string   "encrypted_password",      :default => "",                    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",           :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "fb_token"
    t.string   "managing_company"
    t.boolean  "send_notification_mails", :default => true
    t.integer  "finished_intro_state",    :default => 0
    t.integer  "meta_id"
    t.string   "meta_type"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "videos", :force => true do |t|
    t.string   "url"
    t.string   "provider"
    t.string   "title"
    t.text     "description"
    t.string   "keywords"
    t.integer  "duration"
    t.datetime "date"
    t.string   "thumbnail_small"
    t.string   "thumbnail_large"
    t.string   "embed_url"
    t.string   "embed_code"
    t.datetime "video_updated_at"
    t.integer  "videoable_id"
    t.string   "videoable_type"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.text     "user_description"
    t.string   "imdb"
    t.boolean  "primary"
    t.boolean  "is_demo_reel",     :default => false
  end

  create_table "votes", :force => true do |t|
    t.boolean  "is_up_vote",   :default => false
    t.boolean  "is_down_vote", :default => false
    t.integer  "user_id"
    t.integer  "votable_id"
    t.string   "votable_type"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.integer  "value",        :default => 0
  end

  create_table "withdraws", :force => true do |t|
    t.integer  "withdrawable_id"
    t.string   "withdrawable_type"
    t.decimal  "amount",                  :precision => 8, :scale => 2
    t.text     "appears_on_statement_as"
    t.string   "balanced_created_at"
    t.string   "currency"
    t.text     "description"
    t.text     "failure_reason"
    t.string   "failure_reason_code"
    t.string   "href"
    t.string   "balanced_id"
    t.string   "link_customer"
    t.string   "link_destination"
    t.string   "status"
    t.string   "transaction_number"
    t.string   "balanced_updated_at"
    t.datetime "created_at",                                            :null => false
    t.datetime "updated_at",                                            :null => false
  end

  add_index "withdraws", ["withdrawable_id", "withdrawable_type"], :name => "index_withdraws_on_withdrawable_id_and_withdrawable_type"

  add_foreign_key "notifications", "conversations", name: "notifications_on_conversation_id"

  add_foreign_key "receipts", "notifications", name: "receipts_on_notification_id"

end
