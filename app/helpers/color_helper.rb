module ColorHelper
  
  def hexFromString(str, l=0.4, s=0.7)
    h = str.hash % 360
    hslToHex(h, s, l)
  end
  
  def hexToRgb(hex_color) 
    hex_color = hex_color.gsub('#','')
    hex_color.scan(/../).map {|color| color.hex}
  end
  
  def rgbToHex(r,g,b) 
    sprintf("#%02X%02X%02X", r, g, b)
  end
  
  def hexToHsl(hex_color) 
   rgb_color = hexToRgb(hex_color)
   rgbToHsl(*rgb_color)
 end
  
  def hslToHex(h, s, l) 
   rgb_color = hslToRgb(h, s, l)
   rgbToHex(*rgb_color)
 end
  
  def rgbToHsl(r, g, b)
      r /= 255.0
      g /= 255.0
      b /= 255.0
      max = [r, g, b].max
      min = [r, g, b].min
      h = s = l = (max + min) / 2.0

      if max == min 
          h = s = 0.0 #achromatic
      else
          d = max - min
          s = l > 0.5 ? d / (2.0 - max - min) : d / (max + min)
          case max
              when r
                 h = (g - b) / d + (g < b ? 360.0 : 0.0)
              when g
                h = (b - r) / d + 120.0
              when b
                 h = (r - g) / d + 240.0
          end
      end      
      return [h, s, l]
  end

  def hue2rgb(p, q, t)
      t += 1 if t < 0.0
      t -= 1 if t > 1.0
      return p + (q - p) * 6.0 * t if t < 1.0/6.0
      return q if t < 1.0/2.0
      return p + (q - p) * (2.0/3.0 - t) * 6.0 if t < 2.0/3.0
      return p
  end
  
  def hslToRgb(h, s, l)
      if s == 0.0
          r = g = b = l # achromatic
      else
          q = l < 0.5 ? l * (1.0 + s) : l + s - l * s
          p = 2 * l - q
          h /= 360.0
          r = hue2rgb(p, q, h + 1.0/3.0)
          g = hue2rgb(p, q, h)
          b = hue2rgb(p, q, h - 1.0/3.0)
      end
      return [r * 255, g * 255, b * 255]
  end

 
end