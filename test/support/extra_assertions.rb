# duplicates of the python assertions used in eviltransform
def assert_almost_equal(a, b, places = 7)
  assert_equal (a - b).abs.round(places), 0
end

def assert_lt(x, y)
  assert x < y, "#{x} should be less than #{y}"
end
