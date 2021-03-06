include ::Locales::Helper

# Support whyrun
def whyrun_supported?
  true
end

action :add do
  new_resource.locales.each do |locale|
    if locale_available?(locale) || locale == 'C'
      Chef::Log.debug "#{locale} already available - nothing to do."
      next
    end

    converge_by("Add #{locale}") do
      add_locale locale
    end
  end
end

action :set do
  Chef::Log.error('Only set 1 locale') if new_resource.locales.count != 1

  locale = new_resource.locales[0]

  locales locale do
    action :add
  end

  unless ENV['LC_ALL'] == locale and ENV['LANG'] == locale
    converge_by("Set locale to #{locale}") do
      env_variables = %w(LANG LANGUAGE)
      env_variables << 'LC_ALL' if new_resource.lc_all

      env_variables.each do |env_var|
        ruby_block "update-locale #{env_var} #{locale}" do
          block { update_locale(env_var, locale) }
          only_if { ENV[env_var] != high_locale_format(locale) }
        end
      end
    end
  end
end

def initialize(name, run_context = nil)
  super
  locales = Array(new_resource.locales)
  charmap = parsed_locale(locales[0])['charmap'] rescue 'UTF-8'
  @new_resource.charmap charmap if @new_resource.charmap.nil?
  @new_resource.locales locales
end

def add_locale(locale)
  run_context.include_recipe 'locales::install'

  ruby_block "add locale #{locale}" do
    block do
      `touch #{node['locales']['locale_file']}`
      file = Chef::Util::FileEdit.new node['locales']['locale_file']
      line = "#{high_locale_format(locale)} #{new_resource.charmap}"
      file.insert_line_if_no_match(/^#{line}$/, line)
      file.write_file
    end
    notifies :run, 'execute[locale-gen]', :immediate
  end
end

def update_locale(variable, locale)
  cmd = "update-locale #{variable}=#{high_locale_format(locale)}"
  Mixlib::ShellOut.new(cmd).run_command
  ENV[variable] = locale
end
