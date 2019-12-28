#!/usr/bin/env ruby

require 'selenium-webdriver'
require 'httparty'

IMGS_DIR = File.join __dir__, 'vkload', 'imgs'

print "enter email: "
email = gets.chomp
print "enter password: "
pass = gets.chomp
print "enter name of contanct: "
from_whom = gets.chomp
print "enter amount of pics to download: " 
amount = gets.chomp.to_i

driver = Selenium::WebDriver.for :firefox
driver.navigate.to "http://vk.com"

email_input = driver.find_element(id: 'index_email')
pass_input = driver.find_element(id: 'index_pass')
submit_login = driver.find_element(id: 'index_login_button')

email_input.send_keys email
pass_input.send_key pass
submit_login.submit

wait = Selenium::WebDriver::Wait.new(timeout: 10)

sleep 6

#wait.until { driver.find_element(id: 'l_msg') }

mes_button = driver.find_element(id: 'l_msg')
mes_button.click

sleep 6

#wait.until { driver.find_element(class: 'nim-dialog--cw') }

driver.find_elements(class: 'nim-dialog--cw').each do |mbox|
  puts mbox.text
  puts "==========="
  if mbox.text.include? from_whom
    mbox.click
    break
  end
end

_dots = driver.find_elements(class: 'ui_actions_menu_icons', role: 'button', tabindex: '0', onclick: "uiActionsMenu.keyToggle(this, event);")

dots = nil
_dots.each do |e|
  if e.text.empty?
    dots = e
    break
  end
end

dots.click

attchs = driver.find_elements class: 'ui_actions_menu_item' ,'data-action':  "photos"
attchs = attchs[-4] #very unreliable

attchs.click

sleep 6

#wait.until { driver.find_element class: 'photos_row' }

first_photo = driver.find_elements class: 'photos_row'
first_photo = first_photo.first
first_photo.click

sleep 6

#wait.until { driver.find_element id: 'pv_photo' }


amount.times do |i| 
  div_img = driver.find_element id: 'pv_photo'
  img = div_img.find_element tag_name: 'img'
  src = img.attribute 'src'
  puts "getting the #{src}..."
  jpg = HTTParty.get src.gsub "https", "http"
  File.write (File.join IMGS_DIR, "#{from_whom}_#{i}.jpg"), jpg
  driver.execute_script "cur.pvClicked = true; Photoview.show(false, cur.pvIndex + 1, event);"
end

#binding.irb
