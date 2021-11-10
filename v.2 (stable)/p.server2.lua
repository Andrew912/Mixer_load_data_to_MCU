local
p={
    STATUS_CHECK_COUNTER    = 0;
    STOP_AFTER_ATTEMPTS     = 40;
    myTimer     = 1;                -- Номер таймера, используемый подпрограммой
    myTimerInt  = 1000;             -- Интервал опроса таймера
    cfgfile     = 'cfg.me';
    cfg_IP_file = 'cfg.ip';
    cfgfileNow  = false;
    pattern     = '(.*):([^\n]*)';  -- выделяем строку без символа конца строки
    myRead      = '';
    myName      = '';
    myPort      = 0;
    dataData    = '0';              -- буфер для копирования принятой строки
    dataToSend  = 'no data';        -- строка для отправки получателю
    dataNow     = 0;                -- наличие новых данных от UART
}



--  Запуск сервера
function start_server ()
    
    -- Чтение имени сервера из файла
    print('p.cfgfile: ',p.cfgfile)
    myFile              = file.open     (p.cfgfile)
    p.myName, p.myPort  = string.match  (myFile.read(),p.pattern)
    file.close()
    
    -- Строка ответа сервера
    p.dataToSend = "server='"..p.myName.."'data='"..p.dataData.."'\r"
    print('dataToSend: '..p.dataToSend)
    
    -- Запуск сервера
    srv = net.createServer(net.TCP) 
    
    -- Запуск последовательного порта
    uart.setup(0,9600,8,0,1,0)
    
    -- При поступлении данных в порт
    uart.on("data",
        "\r",
        function(data)
            p.dataData = string.gsub(string.gsub(data,"\r","")," ","")
            p.dataToSend    = "server='"..p.myName.."'data='"..p.dataData.."'\r"
            end
        ,0)
    
    -- Сервер слушает порт
    srv:listen(p.myPort,function(conn) 
        conn:on("receive",function(conn,payload) 
            end) 
        conn:on("connection", function(conn,payload)
            conn:send(p.dataToSend) 
            conn:close()
            end)
        end)

    -- Запускаем контроль работы точки доступа
    start_AP_check ()
    end

--  Получить имя текущей точки доступа
function get_AP_name ()
    myFile              = file.open     (p.cfgfile)
    p.myName, p.myPort  = string.match  (myFile.read(),p.pattern)
    file.close()
    return  p.myName
    end

--  Запуск периодической проверки наличия работающей точки доступа
function start_AP_check ()
    local t={
    timer       = 2;
    interval    = 15000000;
    AP          = get_AP_name ();
    }
--     tmr.alarm(t.timer,t.interval,1,function()
        
--         end)
    end

--  Проверяем наличие соединения (должен быть файл cfg.ip)
tmr.alarm (p.myTimer,p.myTimerInt,1,function ()

    p.cfgfileNow = file.open(p.cfg_IP_file)
    
    print ('Check CFG.IP file...')
    if p.cfgfileNow then
        file.close()
        tmr.stop(p.myTimer)
        start_server ()
        end

    print ('Check attempt counter: ',p.STATUS_CHECK_COUNTER, ' of ',p.STOP_AFTER_ATTEMPTS)
    p.STATUS_CHECK_COUNTER = p.STATUS_CHECK_COUNTER + 1
    if p.STOP_AFTER_ATTEMPTS == p.STATUS_CHECK_COUNTER then
        tmr.stop(p.myTimer)
        print ("Unable to start server...")
        -- Перезапускаем устройство
        node.restart()
        end 
    end)
    
print ('Start SERVER2')
print (node.heap())
