class Post
  include Cequel::Record

  belongs_to :blog
  key :id, :timeuuid, auto: true
  column :title, :text
  column :author_id, :int, index: true
end
