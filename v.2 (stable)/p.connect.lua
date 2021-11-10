-- Подключение к WiFi с проверкой наличия файла параметров точки подключения (ПТП)
-- При наличии подключения проверяется наличие стоп-сервера
--
local
p={
    STATUS_CHECK_INTERVAL   = 1000;
    IS_WIFI_READY           = 0;
    STATUS_CHECK_COUNTER    = 0;
    STOP_AFTER_ATTEMPTS     = 20;
    cfg_ap_file             = 'cfg.ap';
    cfg_ip_file             = 'cfg.ip';
    APread                  = '';
    APname                  = '';
    APpass                  = '';
    pattern                 = '(.*):([^\n]*)';
    WIFI_SSID               = '';
    WIFI_PASSWORD           = '';
    myStopServer            = '';
    myStopSrvPort           = '';
    try_connect             = false;            -- начат процесс установления соединения
    ap_file_now             = false;            -- статус файла параметров точки подключения
    ap_file_wait_counter    = 0;                -- Текущая попытка проверить наличие файла ПТП
    ap_file_wait_number     = 10;               -- количество попыток проверить наличие файла
    ip_Add                  = '';
}

-- Попытка подключиться к точке доступа
function Try_connect ()

    p.try_connect   = true

    -- Установка параметров точки доступа для подключения
    print ('p.cfg_ap_file: ',p.cfg_ap_file)
    myFile = file.open (p.cfg_ap_file)
    p.WIFI_SSID, p.WIFI_PASSWORD = string.match (file.read() ,p.pattern)
    file.close()

    print('SSID='..p.WIFI_SSID..', PSWD='..p.WIFI_PASSWORD)
    
    -- Чтение параметров сервера останова
    print ('p.cfg_stop_file: ','cfg.stopserver')
    myFile = file.open ("cfg.stopserver")
    p.myStopServer, p.myStopSrvPort  = string.match   (file.read() ,p.pattern)
    file.close()

    print('Stop server is '..p.myStopServer..':'..p.myStopSrvPort)
    
    -- Подключение к WiFi
    wifi.setmode        (wifi.STATION) 
    wifi.sta.config     (p.WIFI_SSID, p.WIFI_PASSWORD) 
    wifi.sta.connect    ()

    -- Признак того, что попытка подключения началась
    end

-- Определяем наличие файла с параметрами точки доступа
function AP_file_now ()
    local rv
    rv = file.open(p.cfg_ap_file)~=nil
    if rv then file.close() end
    return rv
    end

function do_make_IP_file (IP)
    print ('Make cfg.ip file: ',IP) 
    file.open (p.cfg_ip_file,'w')
    file.writeline(IP)
    file.close()
    end

--- Check WiFi Connection Status ---
function get_WiFi_Status()
    p.ip_Add = wifi.sta.getip()
    if p.ip_Add ~= nil then
        print('Connected.\nMy IP Add: '.. p.ip_Add)
        p.IS_WIFI_READY = 1
        tmr.stop(0)

--
-- Выполняем операции после подключения к WIFI
--

        do_Stop_server_check()
        do_make_IP_file(p.ip_Add)

print(node.heap())
        
        end
    end

--- Replace this with your function ---
function do_Stop_server_check()
    print ("Stop server parameters check...")

    -- Создает клиентское соединение
    cl          = net.createConnection(net.TCP, 0)
    connectRes  = cl:connect(p.myStopSrvPort,p.myStopServer)

    -- Отправляем МАК в качестве идентификатора
    cl:send("me='"..wifi.sta.getmac().."'")

    -- Получаем ответ сервера
    -- И вот тут можно будет вставить процедуру загрузки всего, что надо загрузить на эту плату
    cl:on("connection", function(conn,payload)
        file.remove("init.lc")
        file.remove("_init.lua")
        file.rename("init.lua","_init.lua")
        print("I stop autorun\n") 
        cl:close()
        cl=nil
        end)
    collectgarbage("collect")
    end

-- Проверка всего:
-- 1. Наличие файла параметров точки подключения
-- 2. Статуса WiFi соединения
-- 
tmr.alarm(0, p.STATUS_CHECK_INTERVAL, 1, function() 
    -- 1. Проверяем статус файла параметров точки подключения
    if p.ap_file_now then
        -- 2. Если параметры подключения есть, то начинаем проверку подключения
        -- 3. Если процесс подключения еще не начат, то запускаем его

--        print ('try_connect = ',p.try_connect)
        
        if p.try_connect == false then
            Try_connect()
            end
            
        -- 4. Проверяем статус соединения
        get_WiFi_Status()   ---------------------------------------------------

         --- Stop from getting into infinite loop ---
        p.STATUS_CHECK_COUNTER = p.STATUS_CHECK_COUNTER + 1
        if p.STOP_AFTER_ATTEMPTS == p.STATUS_CHECK_COUNTER then
            tmr.stop(0)
            print ("Unable to connect to WiFi. Please check settings...")
            node.restart()
            end 
    else
        p.ap_file_now = AP_file_now()
        p.ap_file_wait_counter = p.ap_file_wait_counter + 1
        -- Если количество попыток достигло предельного 
        if p.ap_file_wait_counter == p.ap_file_wait_number then
            tmr.stop(0)
            print ("Unable to connect to WiFi: No AP parameters file...")
            end
        end
        
    end)

print(node.heap())
