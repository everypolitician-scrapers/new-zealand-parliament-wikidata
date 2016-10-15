#!/bin/env ruby
# encoding: utf-8

require 'wikidata/fetcher'

electorate = EveryPolitician::Wikidata.wikipedia_xpath(
  url: 'https://en.wikipedia.org/wiki/New_Zealand_general_election,_2014',
  xpath: '//table[.//caption[contains(.,"Electorate results")]]//td[position() = last() - 5]//a[not(@class="new")]/@title',
)

party = EveryPolitician::Wikidata.wikipedia_xpath(
  url: 'https://en.wikipedia.org/wiki/New_Zealand_general_election,_2014',
  after: '//span[@id="List_results"]',
  before: '//span[@id="Unsuccessful_list_candidates"]',
  xpath: '//table[.//tr[1]//td[.="National"]]//tr[position() > 1]/td//a[not(@class="new")]/@title',
)

wikipedia = EveryPolitician::Wikidata.morph_wikinames(source: 'everypolitician-scrapers/new-zealand-parliament-wikipedia', column: 'wikiname')

extras = [ 'Ria Bond', 'Maureen Pugh', 'Marama Davidson', 'Barry Coates' ]

EveryPolitician::Wikidata.scrape_wikidata(names: { en: electorate | party | wikipedia | extras }, output: false)


