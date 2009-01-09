require File.dirname(__FILE__) + '/base'

class TestAlbum < Test::Unit::TestCase
  context "Album class" do
    context "with address, name, description, user_id" do
      setup do
        @address = 'http://localhost:3000/albums/'
        @name = 'test album'
        @description = 'this is a test album.'
        @user_id = 1
      end

      should "be able to create an album" do
        # skip test remote create an album
        Album.expects(:create).returns(1)
        album_id = Album.create(@address, @user_id, @name, @description)
        assert_not_nil album_id
      end

      should "not include slash symbol in the album name" do
        assert_nil @name.match(/\//)
        assert_nil @name.match(/\\/)
      end
    end
  end
end
