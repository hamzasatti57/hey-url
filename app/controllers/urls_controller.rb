# frozen_string_literal: true

class UrlsController < ApplicationController
  require 'uri'
  require 'resolv'
  require 'browser'

  def index
    @url = Url.new
    @urls = Url.all.order(:created_at).limit(10)
  end

  def create
    url = params[:url][:original_url] =~ URI::DEFAULT_PARSER.make_regexp
    return redirect_to urls_path, notice: 'Invalid Url!' unless url.zero?

    short_url = make_short_url
    @url = Url.new(original_url: params[:url][:original_url], short_url: short_url)
    @url.save
    redirect_to urls_path, notice: 'Successfully created!'
  end

  def show
    @url = Url.find_by(short_url: params[:url])
    @urls = Url.all.order(:created_at).limit(10)
    @urls.each do |url|
      @daily_clicks = [
        ['1', url.clicks.count],
        ['2', url.clicks.count],
        ['3', url.clicks.count],
        ['4', url.clicks.count],
        ['5', url.clicks.count],
        ['6', url.clicks.count],
        ['7', url.clicks.count],
        ['8', url.clicks.count],
        ['9', url.clicks.count],
        ['10', url.clicks.count]
      ]
    end
    @browsers_clicks = [
      ['IE', @url.clicks.where(browser: 'IE').count],
      ['Firefox', @url.clicks.where(browser: 'Firefox').count],
      ['Chrome', @url.clicks.where(browser: 'Chrome').count],
      ['Safari', @url.clicks.where(browser: 'Safari').count]
    ]
    @platform_clicks = [
      ['Windows', @url.clicks.where(platform: 'Windows').count],
      ['macOS', @url.clicks.where(platform: 'macOS').count],
      ['Ubuntu', @url.clicks.where(platform: 'Ubuntu').count],
      ['Other', @url.clicks.where(platform: 'Other').count]
    ]
  end

  def visit
    # params[:short_url]
    render plain: 'redirecting to url...'
  end

  def counter
    return unless params[:url][:id].present?

    url = Url.find(params[:url][:id])
    url.update(clicks_count: url.clicks_count + 1)

    create_click(url)
    redirect_to urls_path
  end

  private

  def make_short_url
    random_string = (0...50).map { ('a'..'z').to_a[rand(26)] }.join
    random_string.first(5).upcase
  end

  def create_click(url)
    browser = Browser.new(url.original_url.to_s, accept_language: 'en-us')
    platform = if browser.platform.windows?
                 'Windows'
               elsif browser.platform.mac?
                 'macOS'
               elsif browser.platform.linux?
                 'Ubuntu'
               elsif browser.platform.unknown?
                 'Other'
               else
                 ''
               end
    browser_name = if browser.ie?
                     'IE'
                   elsif browser.firefox?
                     'Firefox'
                   elsif browser.chrome?
                     'Chrome'
                   elsif browser.safari?
                     'Safari'
                   else
                     ''
                   end
    Click.create(browser: browser_name, platform: platform, url_id: url.id)
  end
end
