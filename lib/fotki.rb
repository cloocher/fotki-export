# Copyright 2011 Gene Drabkin
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and

require 'watir-webdriver'
require 'open-uri'

class Fotki

  def initialize(username, password, directory, browser = :firefox)
    @username, @password, @directory, @browser = username, password, directory, browser
    @client = Watir::Browser.new(@browser)
  end

  def export
    @client.goto('http://fotki.com')

    # logout if logged in
    logout_link = @client.link(:title, 'Logout...')
    logout_link.click if logout_link.exists?

    # login
    puts 'logging in'
    @client.goto('http://login.fotki.com/')
    @client.text_field(:name, 'login').set(@username)
    @client.text_field(:name, 'password').set(@password)
    @client.button(:value, 'Login').click

    photo_count = 0
    puts 'opening all albums'
    @client.goto('http://public.fotki.com/Lenocheka/')
    puts 'going through every album folder'
    folder_links = @client.div(:id, 'dtree').links
    folder_links.each do |folder_link|
      # only open folders with photos
      if folder_link.href.downcase.match(/my-pic\/\w+\//i)
        puts "opening folder #{folder_link.text}"
        @client.goto(folder_link.href)
        picture_folder_url = @client.url

        puts 'going through every album'
        albums_div = @client.div(:id, 'albums_loop')
        album_index = 1
        # loop through all albums
        loop do
          album_link = albums_div.link(:class => 'title', :index => album_index)
          # stop when no more albums left
          break unless album_link.exists?
          album_name = album_link.text.gsub(/\//, ' - ')
          puts "album ##{album_index} \"#{album_name}\""
          album_link.click

          dir_path = "#{@directory}/#{album_name}"
          # skip albums that have been downloaded already
          unless File.exists?(dir_path)
            puts 'loading first photo in album'
            first_link = @client.link(:xpath, "//div[@class='thumbnails']//a/img/..")
            first_link.click

            puts 'downloading all photos within album'
            # loop through all photos within album
            loop do
              download_link = @client.link(:xpath, "//li[@class='single']/a[contains(@href, 'http://images')]")
              if download_link.exists?
                photo_url = download_link.href
                photo_name = photo_url.split(/\//).last

                `mkdir -p "#{dir_path}"`
                file_path = "#{dir_path}/#{photo_name}"
                # download photo
                unless File.exist?(file_path)
                  photo_count += 1
                  puts "[#{photo_count}] downloading photo #{photo_name}"
                  File.open(file_path, 'w') do |output|
                    open(photo_url) do |input|
                      output << input.read
                    end
                  end
                end
              end

              count_link = @client.link(:id, 'btn_thumbs')
              counts = count_link.spans.last.text.split(/\//).map { |e| e.to_i }
              # go to next photo unless on the last one
              break if counts.first == counts.last
              photo_nav_div = @client.div(:id, 'photo_navig')
              photo_nav_div.link(:text, 'Next').click
            end
          end

          album_index += 1
          @client.goto(picture_folder_url)
        end
      end
    end
  end
end
