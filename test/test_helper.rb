puts "test_helper loading!"
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "eviltransform"
require "minitest/autorun"
require File.expand_path("test/support/extra_assertions")

