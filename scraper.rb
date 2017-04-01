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

# Find all members of (terms that started after 2002)
query = <<EOS
  SELECT DISTINCT ?item
  WHERE
  {
    BIND(wd:Q18145518 AS ?membership)
    ?item p:P39 ?position_statement .
    ?position_statement ps:P39 ?membership .
    ?position_statement pq:P2937 ?term .
    ?term wdt:P571 ?start
    FILTER (?start >= "2002-01-01T00:00:00Z"^^xsd:dateTime) .
    SERVICE wikibase:label { bd:serviceParam wikibase:language "en" . }
  }
EOS
p39s = EveryPolitician::Wikidata.sparql(query)

EveryPolitician::Wikidata.scrape_wikidata(ids: p39s, names: { en: electorate | party | wikipedia })


