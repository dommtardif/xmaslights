station_cfg = {}
station_cfg.ssid="XXXX"
station_cfg.pwd="XXXX"
station_cfg.auto=true
station_cfg.save=true
wifi.sta.config(station_cfg)
green = 2
blue = 1
red = 8
m = mqtt.Client(mqtt_client_name, 120)
pwm.setup(green, 150, 0)
pwm.setup(blue, 150, 0)
pwm.setup(red, 150, 0)
pwm.start(green)
pwm.start(blue)
pwm.start(red)
ws2812.init()
buffer = ws2812.newBuffer(7,3)

function arbre(r, g, b)
    pwm.setduty(green, g)
    pwm.setduty(blue, b)
    pwm.setduty(red, r)
end

function locomotive(r, g, b)
    buffer:set(1,g,r,b)
    buffer:set(2,g,r,b)
    buffer:set(3,g,r,b)
    buffer:set(4,g,r,b)
    buffer:set(5,g,r,b)        
    ws2812.write(buffer)
end

function village(n,r, g, b)
    buffer:set(n+5,g,r,b)
    ws2812.write(buffer)
end

function remap(value,fromlow,fromhigh,tolow,tohigh)
    return (value - fromlow) / (fromhigh - fromlow) * (tohigh - tolow) + tolow
end


function handle_mqtt_error(client, reason) 
  print("MQTT Client failed, trying to reconnect")
  tmr.create():alarm(10 * 1000, tmr.ALARM_SINGLE, do_mqtt_connect)
end

function do_mqtt_connect()
  m:connect("192.168.1.4", mqtt_on_connect, handle_mqtt_error)
end

function mqtt_on_connect(client) 
    print ("MQTT connected")
    m:subscribe("lumieresnoel/village/arbre",0, function(conn) print("subscribe success") end)
    m:subscribe("lumieresnoel/village/locomotive",0, function(conn) print("subscribe success") end)
    m:subscribe("lumieresnoel/village/sol/#",0, function(conn) print("subscribe success") end)
end

m:on("offline", function(client)
    print ("MQTT offline")
end)

m:on("message", function(client, topic, data)

  if data ~= nil then
    r,g,b = string.match(data, '(%d+),%s(%d+),%s(%d+)')
    r = tonumber(r)
    g = tonumber(g)
    b = tonumber(b)
        if topic == "lumieresnoel/village/arbre" then
            -- r = (tonumber(r)/255)*1023
            -- g = (tonumber(g)/255)*1023
            -- b = (tonumber(b)/255)*1023
            r = remap(r,0,255,0,1023)
            g = remap(g,0,255,0,900)
            b = remap(b,0,255,0,900)
            arbre(r,g,b)
            --print(r)
            --print(g)
            --print(b)
        elseif topic == "lumieresnoel/village/locomotive" then 
            locomotive(r,g,b)
        elseif topic == "lumieresnoel/village/sol/1" then 
            village(1,r,g,b)
        elseif topic == "lumieresnoel/village/sol/2" then
            village(2,r,g,b)
        end
        
  end
end)

do_mqtt_connect()



