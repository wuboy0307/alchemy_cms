require 'spec_helper'

describe Alchemy::Admin::EssencesHelper do
  include Alchemy::Admin::ElementsHelper

  let(:element) { FactoryGirl.create(:element, :name => 'article', :create_contents_after_create => true) }

  describe 'essence rendering' do
    before do
      element.content_by_name('intro').essence.update_attributes(:body => 'hello!')
    end

    it "should render an essence editor" do
      content = element.content_by_name('intro')
      helper.render_essence_editor(content).should match(/input.+type="text".+value="hello!/)
    end

    it "should render an essence editor by name" do
      helper.render_essence_editor_by_name(element, 'intro').should match(/input.+type="text".+value="hello!/)
    end

    it "should render an essence editor by type" do
      helper.render_essence_editor_by_type(element, 'EssenceText').should match(/input.+type="text".+value="hello!/)
    end
  end

  describe '#pages_for_select' do
    let(:contact_form) { FactoryGirl.create(:element, :name => 'contactform', :create_contents_after_create => true) }
    let(:page_a) { FactoryGirl.create(:public_page, :name => 'Page A') }
    let(:page_b) { FactoryGirl.create(:public_page, :name => 'Page B') }
    let(:page_c) { FactoryGirl.create(:public_page, :name => 'Page C', :parent_id => page_b.id) }

    before do
      # to be shure the ordering is alphabetic
      page_b
      page_a
      helper.session[:language_id] = 1
    end

    context "with no arguments given" do
      it "should return options for select with all pages ordered by lft" do
        helper.pages_for_select.should match(/option.*Page B.*Page A/m)
      end

      it "should return options for select with nested page names" do
        page_c
        output = helper.pages_for_select
        output.should match(/option.*Startseite.*>&nbsp;&nbsp;Page B.*>&nbsp;&nbsp;&nbsp;&nbsp;Page C.*>&nbsp;&nbsp;Page A/m)
      end
    end

    context "with pages passed in" do
      before do
        @pages = []
        3.times { @pages << FactoryGirl.create(:public_page) }
      end

      it "should return options for select with only these pages" do
        output = helper.pages_for_select(@pages)
        output.should match(/#{@pages.collect(&:name).join('.*')}/m)
        output.should_not match(/Page A/m)
      end

      it "should not nest the page names" do
        output = helper.pages_for_select(@pages)
        output.should_not match(/option.*&nbsp;/m)
      end
    end
  end

end
