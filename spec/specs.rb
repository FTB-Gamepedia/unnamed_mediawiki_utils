require 'minitest/autorun'
require_relative '../lib/mediawiki/utils'

UTIL = MediaWiki::Utils.new('https://ftb.gamepedia.com/api.php')

describe 'MediaWiki::Utils' do
  it '#namespacify' do
    assert_equal('Category:Butt', UTIL.namespacify('Category', 'Butt'))
    assert_equal('Butt:Category', UTIL.namespacify('butt', 'Category'))
    assert_equal('Namespace:page', UTIL.namespacify('Namespace', 'page'))
  end
end
