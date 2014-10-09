#
# Cookbook Name:: locales
# Recipe:: default
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

extend ::Locales::Helper

node['locales']['packages'].each do |pack|
  package pack
end

locales node['locales']['default'] do
  action :set
end

node['locales']['available'].each do |locale|
  locales locale do
    action :add
  end
end

