-- Главная таблица, содержит все данные приложения
local
p={
    TAG             = 'setaplist: ';-- 
    ipfile          = 'cfg.ip';     -- имя файла с IP-адресом при подключении (используется connect и server)
    apfile          = 'cfg.ap';     -- имя файла с параметрами точки доступа
    aplist          = 'cfg.aplist'; -- имя файла списка доступных точек доступа
    i               = 0;            -- счетчик
    line            = '';           -- строка, считываемая из файла
    ap              = '';           -- точка доступа, к которой надо подключаться
    net             = '';           -- имя сети из прочитанной строки
    stop            = 0;            -- признак выхода из цикла анализа
    filemode_read   = 'r';          -- 
    filemode_write  = 'w';
    EOL             = '\n'
    }

-- Удаляет файл точки подключения
-- До появления этого файла подключения к WiFi не производится

function clearfile()
    -- Удаление cfg.ap
    print (p.TAG..'apfile: ',p.apfile)
    if file.open(p.apfile,p.filemode_read) then
        file.close()
        file.remove(p.apfile)
        end
    -- Удаление cfg.ip
    print (p.TAG..'ipfile: ',p.ipfile)
    if file.open(p.ipfile,p.filemode_read) then
        file.close()
        file.remove(p.ipfile)
        end
    end

-- Получает список всех точек доступа, имеющихся в эфире
-- Данные пишутся в таблицу в виде нумерованного списка

function listap(t)
--    print(p.EOL)
    for k,v in pairs(t) do
        p.i    = p.i + 1
        p[p.i] = k
        end
    testap()
    end

-- Проверка наличия в эфире точек доступа из списка разрешенных
-- Выбор производится первой в файле по списку точки доступа 

function testap()
    local j
    print ('testap')
    print (p.TAG..'testap: main.aplist: ',p.aplist)
    file.open(p.aplist,p.filemode_read)
    repeat
        p.line=file.readline() 
        if p.line ~= nil then

            -- Выделяем имя сети и пароль, убираем перевод строки
            p.net = string.gsub(p.line,"(%w+):(%w*)(\n*)","%1")
            print (p.EOL..'Testing NET: '..p.net..p.EOL) 

            j = 1
            while j <= p.i do

                print ('main['..j..']='..p[j]..' -> '..p.net)
                
                if p[j]==p.net then
                    p.ap     = p.line
                    p.stop   = 1
                    j        = p.i + 1
                    set_ap_file(p.line)
                    end
                  
                j = j + 1
                end
           end
        until p.stop==1

    file.close()
    print ('Alles!')
    end

-- Запись параметров точки доступа в файл
function set_ap_file(apname)
    print(p.TAG..'I save file with '..apname)
    file.open(p.apfile,p.filemode_write)
    file.write(p.ap)
    file.close()
    end

-- ===============
-- Основной модуль 
-- ===============
print ('=== RUN SetAPlist') 

wifi.setmode(wifi.STATION)
clearfile()
wifi.sta.getap(listap)
print(node.heap())
