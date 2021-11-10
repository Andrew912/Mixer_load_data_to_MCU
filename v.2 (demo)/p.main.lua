print ('=== RUN Main') 

dofile  ('p.compiler.lc')       --

dofile  ('p.setaplist.lc')      -- 

dofile  ('p.connect.lc')        -- uses timer 0

--print(node.heap())
--collectgarbage("collect")

dofile  ("p.server2.lc")        -- uses timer 1

print(node.heap())
