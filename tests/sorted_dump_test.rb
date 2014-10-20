

require 'test/unit'

require 'cookbooks/master_chef/libraries/sorted_dump'

class TestSortedDump < Test::Unit::TestCase

	def test_one_level
		assert_equal SortedJsonDump.recurse_merge({:a => 2}), {"a" => 2}
	end

	def test_two_level
		assert_equal SortedJsonDump.recurse_merge({:a => {:b => 3}, "a" => {:c => 4}}), {"a" => {"b" => 3, "c" => 4}}
	end

	def test_three_level
		assert_equal SortedJsonDump.recurse_merge({:a => {:b => {:c => 5}}, "a" => {"b" => {"d"  => 4}}}), {"a" => {"b" => {"c" => 5, "d" => 4}}}
	end
end