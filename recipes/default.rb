# recipes/default.rb
#
# Author: Simple Finance <ops@simple.com>
# License: Apache License, Version 2.0
#
# Copyright 2013 Simple Finance Technology Corporation
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
# limitations under the License.
#
# Installs InfluxDB

require 'pp'

ver  = node[:influxdb][:version]
arch = /x86_64/.match(node[:kernel][:machine]) ? 'amd64' : 'i686'
node.default[:influxdb][:source] = "http://s3.amazonaws.com/influxdb/influxdb_#{ver}_#{arch}.deb"
dirs = node[:influxdb][:data_root_dir]
influxdb_config = node[:influxdb][:config]

if Gem::Version.new(ver) < Gem::Version.new('0.9.0')
  node.set[:influxdb][:config_file_path] = "#{node[:influxdb][:install_root_dir]}/shared/config.toml"
elsif Gem::Version.new(ver) < Gem::Version.new('0.9.2')
  dirs = [node[:influxdb][:data_root_dir], influxdb_config[:data][:dir], influxdb_config[:broker][:dir]]
end

pp_influxdb = PP.pp(node[:influxdb], '')
Chef::Log.info "++++ influxdb:\n#{pp_influxdb}"

directory node[:influxdb][:data_root_dir] do
  mode "0755"
  owner "influxdb"
  group "influxdb"
  recursive true
end

influxdb 'main' do
  source node[:influxdb][:source]
  config influxdb_config
  action node[:influxdb][:action]
end
