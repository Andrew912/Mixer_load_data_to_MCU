-- start INIT.LUA

p = {
    compilerNow = 0;
}   

print ('start INIT.LUA')

-- Проверка наличия скомпиллированного компилера
myFile = file.open('p.compiler.lc','r')
if myFile~=nil 
then
    -- Есть скомпиллированный компиллятор
    p.compilerNow = 1
    file.close()
else
    myFile = file.open('p.compiler.lua','r')
    if myFile~=nil then
        -- Есть нескомпиллированный компиллятор
        p.compilerNow = 2
        file.close()
        end
    end
    
if p.compilerNow == 2 
    then
    dofile("p.compiler.lua")
    end

if p.compilerNow == 1
    then
    dofile("p.compiler.lc")
    end

dofile("p.main.lc")
