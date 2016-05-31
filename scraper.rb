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

term_50 = EveryPolitician::Wikidata.wikipedia_xpath(
  url: 'https://en.wikipedia.org/wiki/50th_New_Zealand_Parliament',
  after: '//span[@id="Members"]',
  before: '//span[@id="Parliamentary_business"]',
  xpath: '//table//tr//td[2]//a[not(@class="new")]/@title',
)

extras = [ 'Ria Bond', 'Maureen Pugh', 'Marama Davidson' ]

EveryPolitician::Wikidata.scrape_wikidata(names: { en: electorate | party | term_50 | extras }, output: false)


