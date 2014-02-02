require_relative './spec_helper'

describe Cequel::Record::OrmAdapter do
  let!(:blog) { Blog.create!(subdomain: 'cassandra', name: 'Cassandra') }
  let!(:posts) do
    5.times.map do |i|
      Post.create!(blog: blog, title: "Cequel #{i}")
    end
  end
  let(:post) { posts.first }
  let(:blog_adapter) { Blog.to_adapter }
  let(:post_adapter) { Post.to_adapter }
  subject { post_adapter }

  its(:column_names) { should == [:blog_subdomain, :id, :title, :author_id] }

  describe '#get!' do
    it 'should get a simple primary key' do
      blog_adapter.get!([blog.subdomain]).should == blog
    end

    it 'should get a simple primary key not specified as an array' do
      blog_adapter.get!(blog.subdomain).should == blog
    end

    it 'should get a compound primary key' do
      post_adapter.get!(post.key_values).should == post
    end

    it 'should raise an error if key not found' do
      expect { blog_adapter.get!(['foo']) }.to raise_error
    end
  end

  describe '#get' do
    it 'should get a simple primary key' do
      blog_adapter.get([blog.subdomain]).should == blog
    end

    it 'should return nil if key not found' do
      blog_adapter.get(['foo']).should be_nil
    end
  end

  describe '#find_first' do
    let!(:other_post) do
      Post.create!(blog_subdomain: 'postgres', title: 'Sequel', author_id: 1)
    end

    it 'should find first with no conditions' do
      post_adapter.find_first.should == post
    end

    it 'should find first with conditions' do
      post_adapter.find_first(conditions: {blog_subdomain: 'postgres'})
        .should == other_post
    end

    it 'should find first with secondary index condition' do
      post_adapter.find_first(conditions: {author_id: 1})
        .should == other_post
    end

    it 'should accept bare conditions' do
      post_adapter.find_first(blog_subdomain: 'postgres')
        .should == other_post
    end

    it 'should raise an error if key prefix missing' do
      expect { post_adapter.find_first(id: post.id) }
        .to raise_error(ArgumentError)
    end

    it 'should raise an error if order passed' do
      expect { post_adapter.find_first(
        conditions: {blog_subdomain: 'postgres'}, order: [:title, :asc])}
        .to raise_error(ArgumentError)
    end
  end

  describe '#find_all' do
    let!(:other_posts) do
      5.times.map do |i|
        Post.create!(blog_subdomain: 'postgres', title: "Sequel #{i}",
                     author_id: 1)
      end
    end

    it 'should find all with no conditions' do
      post_adapter.find_all.should =~ posts + other_posts
    end

    it 'should find all with conditions' do
      post_adapter.find_all(conditions: {blog_subdomain: 'postgres'})
        .should == other_posts
    end

    it 'should find all with bare conditions' do
      post_adapter.find_all(blog_subdomain: 'postgres')
        .should == other_posts
    end

    it 'should find first with secondary index condition' do
      post_adapter.find_all(author_id: 1)
        .should == other_posts
    end

    it 'should find all with limit' do
      post_adapter.find_all(blog_subdomain: 'postgres', limit: 2)
        .should == other_posts.first(2)
    end

    it 'should raise an error if key prefix missing' do
      expect { post_adapter.find_all(id: post.id) }
        .to raise_error(ArgumentError)
    end

    it 'should raise an error if order passed' do
      expect { post_adapter.find_all(
        conditions: {blog_subdomain: 'postgres'}, order: [:title, :asc]) }
        .to raise_error(ArgumentError)
    end

    it 'should raise an error if offset passed' do
      expect { post_adapter.find_all(
        conditions: {blog_subdomain: 'postgres'}, offset: 2) }
        .to raise_error(ArgumentError)
    end
  end

  describe '#create!' do
    it 'should create instance' do
      post = post_adapter.create!(blog: blog, title: 'New Post')
      Post.find(*post.to_key).title.should == 'New Post'
    end
  end

  describe '#destroy' do
    it 'should destroy instance' do
      post_adapter.destroy(post)
      expect { Post.find(*post.to_key) }
        .to raise_error(Cequel::Record::RecordNotFound)
    end
  end
end
