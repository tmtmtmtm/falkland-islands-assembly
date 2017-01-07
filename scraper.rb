#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'nokogiri'
require 'pry'
require 'scraperwiki'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  noko = noko_for(url)
  noko.css('div.tertiary_content a img').each do |img|
    div = img.xpath('ancestor::div[1]')
    name, constituency = div.css('.wp-caption-text text()')
    data = {
      name:   name.text.tidy.sub('The Honourable ', '').sub(', MLA', ''),
      area:   constituency.text.tidy.gsub(/[()]/, '').sub(' Constituency', ''),
      image:  img.attr('src'),
      term:   2013,
      source: div.css('a/@href').text,
    }
    ScraperWiki.save_sqlite(%i(name term), data)
  end
end

scrape_list('http://www.falklands.gov.fk/self-governance/legislative/assembly-members/')
