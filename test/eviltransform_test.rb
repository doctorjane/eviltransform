require 'benchmark'
require "test_helper"

class EviltransformTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Eviltransform::VERSION
  end

  TESTS = [
    # wgsLat, wgsLng, gcjLat, gcjLng
    [31.1774276, 121.5272106, 31.17530398364597, 121.531541859215], # shanghai
    [22.543847, 113.912316, 22.540796131694766, 113.9171764808363], # shenzhen
    [39.911954, 116.377817, 39.91334545536069, 116.38404722455657] # beijing
  ]

  TESTS_bd = [
    # bdLat, bdLng, wgsLat, wgsLng
    [29.199786, 120.019809, 29.196131605295484, 120.00877901149691],
    [29.210504, 120.036455, 29.206795749156136, 120.0253853970846]
  ]

  def test_wgs2gcj_shanghai
    wgsLat, wgsLng, gcjLat, gcjLng = TESTS[0]
    new_lat, new_lng = Eviltransform.wgs2gcj(wgsLat, wgsLng)
    assert_almost_equal(new_lat, gcjLat, 6)
    assert_almost_equal(new_lng, gcjLng, 6)
  end

  def test_wgs2gcj_shenzhen
    wgsLat, wgsLng, gcjLat, gcjLng = TESTS[1]
    new_lat, new_lng = Eviltransform.wgs2gcj(wgsLat, wgsLng)
    assert_almost_equal(new_lat, gcjLat, 6)
    assert_almost_equal(new_lng, gcjLng, 6)
  end

  def test_wgs2gcj_beijing
    wgsLat, wgsLng, gcjLat, gcjLng = TESTS[2]
    new_lat, new_lng = Eviltransform.wgs2gcj(wgsLat, wgsLng)
    assert_almost_equal(new_lat, gcjLat, 6)
    assert_almost_equal(new_lng, gcjLng, 6)
  end

  def test_bd2wgs
    TESTS_bd.each do |bdLat, bdLng, wgsLat, wgsLng|
      ret = Eviltransform.bd2wgs(bdLat, bdLng)
      assert_almost_equal(ret[0], wgsLat, 6)
      assert_almost_equal(ret[1], wgsLng, 6)
    end
  end

  def test_gcj2wgs_shanghai
    wgsLat, wgsLng, gcjLat, gcjLng = TESTS[0]
    ret = Eviltransform.gcj2wgs(gcjLat, gcjLng)
    assert_lt(Eviltransform.distance(ret[0], ret[1], wgsLat, wgsLng), 5)
  end

  def test_gcj2wgs_shenzhen
    wgsLat, wgsLng, gcjLat, gcjLng = TESTS[1]
    ret = Eviltransform.gcj2wgs(gcjLat, gcjLng)
    assert_lt(Eviltransform.distance(ret[0], ret[1], wgsLat, wgsLng), 5)
  end

  def test_gcj2wgs_beijing
    wgsLat, wgsLng, gcjLat, gcjLng = TESTS[2]
    ret = Eviltransform.gcj2wgs(gcjLat, gcjLng)
    assert_lt(Eviltransform.distance(ret[0], ret[1], wgsLat, wgsLng), 5)
  end

  def test_gcj2wgs_exact_shanghai
    wgsLat, wgsLng, gcjLat, gcjLng = TESTS[0]
    ret = Eviltransform.gcj2wgs_exact(gcjLat, gcjLng)
    assert_lt Eviltransform.distance(ret[0], ret[1], wgsLat, wgsLng), 0.5
  end

  def test_gcj2wgs_exact_shenzhen
    wgsLat, wgsLng, gcjLat, gcjLng = TESTS[1]
    ret = Eviltransform.gcj2wgs_exact(gcjLat, gcjLng)
    assert_lt Eviltransform.distance(ret[0], ret[1], wgsLat, wgsLng), 0.5
  end

  def test_gcj2wgs_exact_beijing
    wgsLat, wgsLng, gcjLat, gcjLng = TESTS[2]
    ret = Eviltransform.gcj2wgs_exact(gcjLat, gcjLng)
    assert_lt Eviltransform.distance(ret[0], ret[1], wgsLat, wgsLng), 0.5
  end

  def test_z_speed
    n = 100000
    tests = {
      'wgs2gcj' =>
        lambda { Eviltransform.wgs2gcj(TESTS[0][0], TESTS[0][1]) },
      'gcj2wgs' =>
        lambda { Eviltransform.gcj2wgs(TESTS[0][0], TESTS[0][1]) },
      'gcj2wgs_exact' =>
        lambda { Eviltransform.gcj2wgs_exact(TESTS[0][0], TESTS[0][1]) },
      'distance' => lambda { Eviltransform.distance(*TESTS[0]) }
    }

    puts
    puts '='*30
    tests.each do |name, func|
      sec = Benchmark.realtime do
        n.times { func.call }
      end
      puts "%-13s %9.2f ns/op" % [name, sec * 1e9 / n]
    end
    puts
  end
end
