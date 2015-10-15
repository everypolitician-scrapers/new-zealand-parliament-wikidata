#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'wikidata/fetcher'
require 'nokogiri'
require 'colorize'
require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'


def noko_for(url)
  Nokogiri::HTML(open(URI.escape(URI.unescape(url))).read) 
end

def wikidata_ids
  # Member of 51st New Zealand Parliament
  url = 'https://wdq.wmflabs.org/api?q=claim[463:4640115]'
  json = JSON.parse(open(url).read, symbolize_names: true)
  json[:items].map { |id| "Q#{id}" }
end

def wikinames_from(url)
  noko = noko_for(url)
            # numrows => wanted
  wantcol = { 8 => 2, 9 => 3, 10 => 4 }
  electorate = noko.xpath('//table[caption[contains(.,"Electorate results")]]//tr[td[2]]').map { |tr|
    tds = tr.css('td')
    tds[wantcol[tds.count]]
  }.map { |td| td.xpath('.//a[not(@class="new")]/@title').text }

  partylist = noko.xpath('//h3[span[@id="List_results"]]/following-sibling::table[1]//tr[3]//a[not(@class="new")]/@title').map(&:text)

  return (electorate + partylist + wikidata_ids).uniq
end

def fetch_info(names)
  WikiData.ids_from_pages('en', names).each do |name, id|
    data = WikiData::Fetcher.new(id: id).data rescue nil
    unless data
      warn "No data for #{p}"
      next
    end
    data[:original_wikiname] = name
    ScraperWiki.save_sqlite([:id], data)
  end
end

fetch_info wikinames_from('https://en.wikipedia.org/wiki/New_Zealand_general_election,_2014')
