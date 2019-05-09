function hex2rgb (hex)
    local hex = hex:gsub("#","")
    if hex:len() == 3 then
      return (tonumber("0x"..hex:sub(1,1))*17)/255, (tonumber("0x"..hex:sub(2,2))*17)/255, (tonumber("0x"..hex:sub(3,3))*17)/255
    else
      return tonumber("0x"..hex:sub(1,2))/255, tonumber("0x"..hex:sub(3,4))/255, tonumber("0x"..hex:sub(5,6))/255
    end
end

function create_color_resource_hex(hex_color, alpha)
  alpha = alpha or 1
  r, g, b = hex2rgb(hex_color)
  return resource.create_colored_texture(r, g, b, alpha)
end
