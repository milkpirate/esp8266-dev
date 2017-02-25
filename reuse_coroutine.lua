co = coroutine.create(function (f, args)
  while f do
    f = coroutine.yield(f(args))
  end
end)

function dummyFunc(data)
  print("XXX "..data)
  coroutine.yield()
  print("OOO "..data)
end

coroutine.resume(co, dummyFunc, "1")
coroutine.resume(co, dummyFunc, "2")
coroutine.resume(co, dummyFunc, "3")
coroutine.resume(co, dummyFunc, "4")