local
main = {
    nocompile   = 'cfg.nocompile';  --
    pattern_lua = '(%w+).lua';      --
    pattern_no  = '(%w+)\n*';       -- конец строки
    flist       = file.list();      -- общий список файлов на устройстве
    files_nc    = {};               -- Файлы, которые не компилируются
    n_nc        = 0;                -- счетчик файлов files_lc
    }

-- Заполняет таблицу файлов, которые не удаляются
function filenodelete ()
    local line
    if file.open(main.nocompile,'r') then
        repeat
            line = file.readline()
            if line~=nil then
                main.n_nc 
                    = main.n_nc + 1
                main.files_nc[main.n_nc] 
                    = string.gsub(line,main.pattern_no,'%1')
                end
            until line==nil
        end
    end

-- Прверяем имя файла на наличие в списке неудаляемых
function file_nc (filename)
    local i
    for i=1,#main.files_nc,1 do
--    print(''..filename..'='..main.files_nc[i])
        if main.files_nc[i]==filename then
--            print('return 1')
            return 1
            end
        end
--    print('return 0')
    return 0
    end

-- =======================
-- Основной блок программы
-- =======================

print ('===') 
print ('=== RUN PCompiler') 
print ('===') 

filenodelete()

-- print('\nНеудаляемые файлы:')
-- for i=1,main.n_nc,1 do
--     print(main.files_nc[i])
--     end
-- print('\n')

for k,v in pairs(main.flist) do
    if string.match(k,main.pattern_lua) then
        -- Если файл - код LUA, то записываем его в индекс files_lua
        node.compile(k)
        if file_nc(k)==0 then
            print(k..' - delete')
            file.remove(k)
            end
        end
    end

print('\nheap='..node.heap())
