require "eviltransform/version"

module Eviltransform
  def self.outOfChina(lat, lng)
    if (lng >= 72.004 && lng <= 137.8347 && lat >= 0.8293 && lat <= 55.8271)
      return false
    else
      return true
    end
  end

  def self.transform(x, y)
    xy = x * y
    absX = Math.sqrt(x.abs)
    xPi = x * Math::PI
    yPi = y * Math::PI
    d = 20.0*Math.sin(6.0*xPi) + 20.0*Math.sin(2.0*xPi)

    lat = d
    lng = d

    lat += 20.0*Math.sin(yPi) + 40.0*Math.sin(yPi/3.0)
    lng += 20.0*Math.sin(xPi) + 40.0*Math.sin(xPi/3.0)

    lat += 160.0*Math.sin(yPi/12.0) + 320*Math.sin(yPi/30.0)
    lng += 150.0*Math.sin(xPi/12.0) + 300.0*Math.sin(xPi/30.0)

    lat *= 2.0 / 3.0
    lng *= 2.0 / 3.0

    lat += -100.0 + 2.0*x + 3.0*y + 0.2*y*y + 0.1*xy + 0.2*absX
    lng += 300.0 + x + 2.0*y + 0.1*x*x + 0.1*xy + 0.1*absX

    return [lat, lng]
  end

  def self.delta(lat, lng)
    earthR = 6378137.0
    ee = 0.00669342162296594323
    dLat, dLng = transform(lng - 105.0, lat - 35.0)
    radLat = lat / 180.0 * Math::PI
    magic = Math.sin(radLat)
    magic = 1.0 - ee * magic * magic
    sqrtMagic = Math.sqrt(magic)
    dLat = (dLat * 180.0) / ((earthR * (1.0 - ee)) / (magic * sqrtMagic) * Math::PI)
    dLng = (dLng * 180.0) / (earthR / sqrtMagic * Math.cos(radLat) * Math::PI)
    return [dLat, dLng]
  end

  def self.wgs2gcj(wgsLat, wgsLng)
    dlat, dlng = delta(wgsLat, wgsLng)
    return [wgsLat + dlat, wgsLng + dlng]
  end

  def self.gcj2wgs(gcjLat, gcjLng)
    dlat, dlng = delta(gcjLat, gcjLng)
    return [gcjLat - dlat, gcjLng - dlng]
  end

  def self.gcj2wgs_exact(gcjLat, gcjLng)
    initDelta = 0.01
    threshold = 0.000_001
    dLat = dLng = initDelta
    mLat = gcjLat - dLat
    mLng = gcjLng - dLng
    pLat = gcjLat + dLat
    pLng = gcjLng + dLng
    (0...30).each do |i|
      wgsLat = (mLat + pLat) / 2.0
      wgsLng = (mLng + pLng) / 2.0
      tmplat, tmplng = wgs2gcj(wgsLat, wgsLng)
      dLat = tmplat - gcjLat
      dLng = tmplng - gcjLng
      if dLat.abs < threshold and dLng.abs < threshold
        return wgsLat, wgsLng
      end
      if dLat > 0
        pLat = wgsLat
      else
        mLat = wgsLat
      end
      if dLng > 0
        pLng = wgsLng
      else
        mLng = wgsLng
      end
    end
    [wgsLat, wgsLng]
  end

  def self.distance(latA, lngA, latB, lngB)
    earthR = 6378137.0
    pi180 = Math::PI / 180
    arcLatA = latA * pi180
    arcLatB = latB * pi180
    x = (Math.cos(arcLatA) * Math.cos(arcLatB) *
      Math.cos((lngA - lngB) * pi180))
    y = Math.sin(arcLatA) * Math.sin(arcLatB)
    s = x + y
    if s > 1
      s = 1
    elsif s < -1
      s = -1
    end
    alpha = Math.acos(s)
    distance = alpha * earthR
    return distance
  end

  def self.gcj2bd(gcjLat, gcjLng)
    x = gcjLng
    y = gcjLat
    z = Math.hypot(x, y) + 0.00002 * Math.sin(y * Math::PI)
    theta = Math.atan2(y, x) + 0.000003 * Math.cos(x * Math::PI)
    bdLng = z * Math.cos(theta) + 0.0065
    bdLat = z * Math.sin(theta) + 0.006
    return [bdLat, bdLng]
  end

  def self.bd2gcj(bdLat, bdLng)
    x = bdLng - 0.0065
    y = bdLat - 0.006
    z = Math.hypot(x, y) - 0.00002 * Math.sin(y * Math::PI)
    theta = Math.atan2(y, x) - 0.000003 * Math.cos(x * Math::PI)
    gcjLng = z * Math.cos(theta)
    gcjLat = z * Math.sin(theta)
    return [gcjLat, gcjLng]
  end

  def self.wgs2bd(wgsLat, wgsLng)
    lat, lng = wgs2gcj(wgsLat, wgsLng)
    clat, clng = gcj2bd(lat, lng)
    return [clat, clng]
  end

  def self.bd2wgs(bdLat, bdLng)
    return gcj2wgs(*bd2gcj(bdLat, bdLng))
  end

  def self.bd2wgs_exact(bdLat, bdLng)
    return gcj2wgs_exact(*bd2gcj(bdLat, bdLng))
  end
end
