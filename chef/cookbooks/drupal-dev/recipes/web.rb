#
# Cookbook Name:: drupal-dev
# Recipe:: default
#
# Copyright 2013, FCC
#
# All rights reserved - Do Not Redistribute
#
include_recipe 'apt'
include_recipe 'mysql::client'
# map vm folders onto the settings folders so that the vms aren't limited to one per host.

template "/srv/cms/wwwconfig/redirects.conf" do
  mode '0666'
end

template '/srv/cms/wwwconfig/' + node['drupal']['prefix'] + '.serveraliases' do
  mode '0666'
  source 'serveraliases.erb'
end

cookbook_file '/srv/cms/wwwconfig/rewrites.conf' do
  mode '0666'
end

template "/srv/cms/public_html/sites/settings_override/settings.php" do
  mode '0666'
end

['php5', 'php5-mysql', 'php5-gd', 'php-pear', 'php5-dev', 'php5-curl', 'php5-ldap',
'memcached', 'php5-memcached', 'php5-xdebug', 'imagemagick', 'php-apc', 'openjdk-7-jre-headless',
'php5-xmlrpc'].each do |requirement|
  package requirement
end

remote_file "/usr/local/src/drush-5.9.tar.gz" do
  source "https://github.com/drush-ops/drush/archive/5.9.0.tar.gz"
  not_if { File.exists?('/usr/bin/drush') }
  notifies :run, "execute[untar-drush]", :immediately
end

execute "untar-drush" do
  command "tar zxvf drush-5.9.tar.gz"
  user "root"
  cwd "/usr/local/src"
  action :nothing
  notifies :create, "file[/usr/local/src/drush-5.9.0/drush]", :immediately
end

file "/usr/local/src/drush-5.9.0/drush" do
  mode "0755"
  owner "root"
  group "root"
  action :nothing
  notifies :create, "directory[/usr/local/src/drush-5.9.0/lib]", :immediately
end

directory "/usr/local/src/drush-5.9.0/lib" do
  mode "0777"
  owner "root"
  group "root"
  action :nothing
  notifies :create, "link[/usr/bin/drush]", :immediately
end

link "/usr/bin/drush" do
  to "/usr/local/src/drush-5.9.0/drush"
  owner "root"
  action :nothing
end

execute "update-pear" do
  command "pear upgrade"
  user "root"
  not_if { File.exists?('/etc/php5/apache2/uploadprogress.ini') }
end

execute "install-upload-progress" do
  command "pecl install uploadprogress"
  user "root"
  returns [0,1]
  not_if { File.exists?('/etc/php5/apache2/uploadprogress.ini') }
end

service "apache2"

include_recipe 'apache2'
include_recipe 'apache2::mod_rewrite'
include_recipe 'apache2::mod_php5'

template "/etc/apache2/sites-enabled/drupal.conf" do
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, "service[apache2]", :delayed
end

cookbook_file "/etc/php5/conf.d/apc.ini" do
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, "service[apache2]", :delayed
end

cookbook_file "/etc/php5/apache2/php.ini" do
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, "service[apache2]", :delayed
end

cookbook_file "/etc/php5/conf.d/uploadprogress.ini" do
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, "service[apache2]", :delayed
end

cookbook_file "/etc/profile.d/drush.sh" do
  owner 'root'
  group 'root'
  mode '755'
end

template "/etc/php5/conf.d/xdebug.ini" do
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, "service[apache2]", :delayed
end

cookbook_file "/home/vagrant/faster_default_build.sh" do
  owner 'vagrant'
  group 'vagrant'
  mode '0755'
end

cookbook_file "/home/vagrant/faster_live_build.sh" do
  owner 'vagrant'
  group 'vagrant'
  mode '0755'
end
