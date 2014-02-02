class Blog
  include Cequel::Record

  key :subdomain, :ascii
  column :name, :text

  has_many :posts
end
