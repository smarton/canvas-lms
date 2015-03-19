require File.expand_path(File.dirname(__FILE__) + '/common')
require File.expand_path(File.dirname(__FILE__) + '/helpers/files_common')

 describe "better_file_browsing" do
   include_examples "in-process server selenium tests"

   context "As a teacher", :priority => "1" do
      before (:each) do
        course_with_teacher_logged_in
        Account.default.enable_feature!(:better_file_browsing)
        get "/courses/#{@course.id}/files"
      end

        it "should display new files UI" do
          keep_trying_until { expect(f('.btn-upload')).to be_displayed }
        end
   end

   context "File Downloads", :priority => "2" do
      it "should download a file from top toolbar successfully" do
        skip("Skipped until issue with firefox on OSX is resolved")
        download_from_toolbar
      end

      it "should download a file from cog" do
        skip("Skipped until issue with firefox on OSX is resolved")
        download_from_cog
      end

      it "should download a file from file preview successfully" do
        skip("Skipped until issue with firefox on OSX is resolved")
        download_from_preview
      end
   end

   context "Folder Tree", priority: "3" do
     before (:each) do
       course_with_teacher_logged_in
       Account.default.enable_feature!(:better_file_browsing)
       get "/courses/#{@course.id}/files"
     end

     it "should create a new folder" do
       new_folder = create_new_folder
       expect(get_all_files_folders.count).to eq 1
       expect(new_folder.text).to match /New Folder/
     end

     it "should create 15 new child folders and show them in the FolderTree when expanded" do
       create_new_folder
       f('.ef-name-col > a.media').click
       wait_for_ajaximations

       1.upto(15) do |number_of_folders|
        folder_regex = number_of_folders > 1 ? Regexp.new("New Folder\\s#{number_of_folders}") : "New Folder"
        create_new_folder
        expect(get_all_folders.count).to eq number_of_folders
        expect(get_all_folders.last.text).to match folder_regex
       end

       get "/courses/#{@course.id}/files"
       f('ul.collectionViewItems > li > a > i.icon-mini-arrow-right').click
       wait_for_ajaximations
       keep_trying_until { expect(driver.find_elements(:css, 'ul.collectionViewItems > li > ul.treeContents > li.subtrees > ul.collectionViewItems li').count).to eq 15 }
     end
   end

   context "Publish Cloud Dialog", :priority => '3' do
    before (:each) do
      course_with_teacher_logged_in
      Account.default.enable_feature!(:better_file_browsing)
      add_file(fixture_file_upload('files/a_file.txt', 'text/plan'),
               @course, "a_file.txt")
      get "/courses/#{@course.id}/files"
    end

    it "should set focus to the close button when opening the dialog" do
      f('.btn-link.published-status').click
      wait_for_ajaximations
      shouldFocus = f('.ui-dialog-titlebar-close')
      element = driver.execute_script('return document.activeElement')
      expect(element).to eq(shouldFocus)
    end
   end
end
