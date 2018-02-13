require 'erubi'
require 'date'

set :erb, :escape_html => true

if development?
  require 'sinatra/reloader'
  also_reload './command.rb'
end

helpers do
  def dashboard_title
    "Open OnDemand"
  end

  def dashboard_url
    "/pun/sys/dashboard/"
  end

  def title
    "Usage Report"
  end
end

Reports = Struct.new(:range, :count, :cmd)

# Define a route at the root '/' of the app.
get '/' do
  # minutes since end of day
  elapsed_minutes_today = ((DateTime.now.to_time - Date.today.to_time)/60).to_i

  @reports = []

  cmd = %Q[find /var/log/nginx -name access.log -newermt "#{elapsed_minutes_today} minutes ago" | wc -l]
  @reports << Reports.new("Today", `#{cmd}`, cmd)

  cmd = %Q[find /var/log/nginx -name access.log -newermt "#{(Date.today - 1).strftime('%e %b %Y')}" | wc -l]
  @reports << Reports.new("Since Yesterday", `#{cmd}`, cmd)

  cmd = %Q[find /var/log/nginx -name access.log -newermt "1 weeks ago" | wc -l]
  @reports << Reports.new("Since 1 Week Ago", `#{cmd}`, cmd)

  cmd = %Q[find /var/log/nginx -name access.log -newermt "1 months ago" | wc -l]
  @reports << Reports.new("Since 1 Month Ago", `#{cmd}`, cmd)

  cmd = %Q[find /var/log/nginx -name access.log -newermt "3 months ago" | wc -l]
  @reports << Reports.new("Since 3 Months Ago", `#{cmd}`, cmd)

  cmd = %Q[find /var/log/nginx -name access.log -newermt "1 years ago" | wc -l]
  @reports << Reports.new("Since 1 Year Ago", `#{cmd}`, cmd)

  cmd = %Q[ls -1 /var/log/nginx | wc -l]
  @reports << Reports.new("All Time", `#{cmd}`, cmd)

  @error = nil

  # Render the view
  erb :index
end
