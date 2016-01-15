#!/bin/env ruby
# encoding: utf-8

require 'rest-client'
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

def wikinames_from(url)
  noko = noko_for(url)
            # numrows => wanted
  wantcol = { 8 => 2, 9 => 3, 10 => 4 }
  electorate = noko.xpath('//table[caption[contains(.,"Electorate results")]]//tr[td[2]]').map { |tr|
    tds = tr.css('td')
    tds[wantcol[tds.count]]
  }.map { |td| td.xpath('.//a[not(@class="new")]/@title').text }

  partylist = noko.xpath('//h3[span[@id="List_results"]]/following-sibling::table[1]//tr[3]//a[not(@class="new")]/@title').map(&:text)

  hardcoded = [ 'Ria Bond' ]
  return (electorate + partylist + hardcoded).uniq
end

names = wikinames_from('https://en.wikipedia.org/wiki/New_Zealand_general_election,_2014')
EveryPolitician::Wikidata.scrape_wikidata(names: { en: names }, output: true)
warn EveryPolitician::Wikidata.notify_rebuilder


