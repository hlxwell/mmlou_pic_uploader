require File.dirname(__FILE__) + '/base'

class TestFileFinder < Test::Unit::TestCase
  
  context "file finder" do
    context "with root" do
      setup do
        if RUBY_PLATFORM =~ /win/i
          @file_finder = FileFinder.new("E:\\6.Photos\\decrate")
        else
          @file_finder = FileFinder.new('/home/hlxwell/mmlou_pictures')
        end
      end

      should "be able to list all the directories in 1 dir deepth" do
        assert_kind_of Array, @file_finder.all_directories
        assert @file_finder.all_directories.size > 0
      end

      should "be able to list all file for all subdirectory of root directory" do
        @file_finder.all_directories.each do |dir|
          @file_finder.all_files(dir).each do |file|
            assert File.file?(file)
          end
          assert @file_finder.all_files(dir).size > 0
        end
      end
    end
  end

end
