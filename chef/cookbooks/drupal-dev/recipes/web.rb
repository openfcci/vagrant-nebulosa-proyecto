#
# Cookbook Name:: drupal-dev
# Recipe:: default
#
# Copyright 2013, FCC
#
# All rights reserved - Do Not Redistribute
#
include_recipe 'apt'

['php5', 'php5-mysql', 'php5-gd', 'php-pear', 'php5-dev', 'php5-curl', 'php5-ldap',
'memcached', 'php5-memcached', 'imagemagick', 'php-apc'].each do |requirement|
  package requirement
end

execute "update-pear" do
  command "pear upgrade"
  user "root"
end

execute "add-pear.drush.org" do
  command "pear channel-discover pear.drush.org"
  user "root"
  returns [0,1]
end

execute "install-drush" do
  command "pear install drush/drush"
  user "root"
  returns [0,1]
end

directory "/usr/share/php/drush/lib" do
  owner 'vagrant'
  mode '0775'
end

execute "install-upload-progress" do
  command "pecl install uploadprogress"
  user "root"
  returns [0,1]
end

include_recipe 'apache2'
include_recipe 'apache2::mod_rewrite'
include_recipe 'apache2::mod_php5'

service "apache2"

template "/etc/apache2/sites-enabled/drupal.conf" do
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, "service[apache2]", :delayed
end

file "/etc/php5/conf.d/apc.ini" do
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, "service[apache2]", :delayed
end

file "/etc/php5/apache2/php.ini" do
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, "service[apache2]", :delayed
end

file "/etc/php5/conf.d/uploadprogress.ini" do
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, "service[apache2]", :delayed
end

# map vm folders onto the settings folders so that the vms aren't limited to one per host.

directory "/usr/local/wwwconfig" do
  owner 'vagrant'
  mode '0775'
end

directory "/usr/local/settings_override" do
  owner 'vagrant'
  mode '0775'
end

execute "mount-wwwconfig" do
  command 'mount -o bind /usr/local/wwwconfig/ /srv/cms/wwwconfig/'
  user 'root'
end

execute "mount-settings_override" do
  command 'mount -o bind /usr/local/settings_override/ /srv/cms/public_html/sites/settings_override/'
  user 'root'
end
