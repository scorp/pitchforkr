require 'activerecord'
require "will_paginate"

WillPaginate.enable_activerecord

ActiveRecord::Base.establish_connection({:adapter=>"sqlite3", 
  :dbfile => "/Users/will/db/pitchfork-reviews.db"})
  
# models
class Review < ActiveRecord::Base
  validates_uniqueness_of :content_id
end

unless Review.table_exists?
  ActiveRecord::Migration.create_table :reviews do |t|
    t.integer   :content_id
    t.string    :full_title
    t.string    :artist
    t.string    :title
    t.string    :imaage_url
    t.float     :rating
    t.text      :review
    t.text      :review_summary
    t.text      :original_doc
  end
end
