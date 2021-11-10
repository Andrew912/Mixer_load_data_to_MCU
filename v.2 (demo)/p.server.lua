p={
    cfgfile     = 'cfg.me';
    pattern     = '(.*):([^\n]*)';           -- выделяем строку без символа конца строки
    myRead      = '';
    myName      = '';
    myPort      = 0;
    dataData    = '0';                  -- буфер для копирования принятой строки
    dataToSend  = 'no data';            -- строка для отправки получателю
    dataNow     = 0;                    -- наличие новых данных от UART
}

-- Чтение имени сервера из файла
myFile              = file.open     (p.cfgfile)
p.myName, p.myPort  = string.match  (myFile.read(),p.pattern)
file.close()

-- Строка ответа сервера
p.dataToSend = "server='"..p.myName.."'data='"..p.dataData.."'"
print('dataToSend: '..p.dataToSend)

-- Запуск сервера
srv = net.createServer(net.TCP) 

-- Запуск последовательного порта
uart.setup(0,9600,8,0,1,0)

-- При поступлении данных в порт
uart.on("data",
    "\r",
    function(data)
        p.dataData = string.gsub(data,"\r","")
        p.dataNow  = 1
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

tmr.alarm(6,500,1,function()
    if p.dataNow == 1 then                 -- если есть новые данные от UART
        p.dataNow       = 0
        p.dataToSend    = "server='"..p.myName.."'data='"..p.dataData.."'\r"
        p.dataData      = ""
        end
    end)
