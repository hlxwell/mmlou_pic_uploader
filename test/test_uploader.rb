require File.dirname(__FILE__) + '/base'

class TestUploader < Test::Unit::TestCase

  context "uploader" do
    setup do
      if RUBY_PLATFORM =~ /win/i
        @dir = "E:\\6.Photos\\decrate"
      else
        @dir = '/home/hlxwell/mmlou_pictures'
      end
      @uploader = Uploader.new(@dir)
      @filename = '/home/hlxwell/mmlou_pictures/a/apps.facebook.com__babywallaby.jpg'
    end

    should "be able to record uploaded photos" do
      assert @uploader.record_uploaded_file(@filename)
      assert @uploader.is_uploaded?(@filename)
    end
    
    context "with upload address and a directory for uploading" do
      setup do
        if RUBY_PLATFORM =~ /win/i
          @dir = "E:\\6.Photos\\decrate"
        else
          @dir = '/home/hlxwell/mmlou_pictures'
        end
        @uploader = Uploader.new(@dir)
      end
      context "after upload" do
        setup do
          # skip test upload to remote
          @uploader.expects(:upload).returns([{:pic_count=>5, :name=>"/home/hlxwell/mmlou_pictures/b"}, {:pic_count=>5, :name=>"/home/hlxwell/mmlou_pictures/a"}])
          @uploaded_albums = @uploader.upload()
        end
        
        should "return an array" do
          assert_not_nil @uploaded_albums
          assert_kind_of Array, @uploaded_albums
        end

        should "uploaded 2 albums" do
          assert @uploaded_albums.size == 2
        end

        context "uploaded_albums' element" do
          should "be hash" do
            assert_not_nil @uploaded_albums.first
            assert_kind_of Hash, @uploaded_albums.first
          end

          should "have 2 keys: name and pic_count" do
            assert_equal @uploaded_albums.first.size, 2
            assert_not_nil @uploaded_albums.first[:name]
            assert_not_nil @uploaded_albums.first[:pic_count]
          end

          should "be number for hash[:pic_count]" do
            assert_kind_of Fixnum, @uploaded_albums.first[:pic_count]
          end

          should "only uploaded more than 1 pictures for first album" do
            assert @uploaded_albums.first[:pic_count] > 1
          end
        end
      end
    end
  end

end
