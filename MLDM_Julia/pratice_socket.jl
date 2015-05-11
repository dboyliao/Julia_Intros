## Get port number through ENV
port = get(ENV, "JULIA_SERVER_PORT", 8000)

function mem_fib_gen()
	cache = Dict{Int64, Int64}()
	function fib(n::Int64)
		if n in keys(cache)
			return cache[n]
		end
		answer = n < 2 ? 1 : fib(n - 1) + fib(n -2)
		cache[n] = answer
		return answer
	end
	return fib
end

# using closure to blocking outer access to inner cache.
fib = mem_fib_gen()

## Start a server socket
server_socket = listen(int64(port))
println("Server running at port $port....")

while true
	conn = accept(server_socket)
	write(conn, "[Info] Welcome to Julia Fibonacci Server ver 1.0\n")
	write(conn, "[Info] My name is fibo and I like to compute fibonacci number!\n")

	# Begin a coroutine using @async macro.
	@async begin
	try # testing the client socket is alive
		while true
			write(conn, "Please enter an integer: ")
			num_string = readline(conn)
			if num_string != "\n"
				num = int64(num_string)
				answer = string(fib(num))
				write(conn, "The answer: $(answer)\n")
			else
				write(conn, "\n")
				write(conn, "Closing connecting. Bye bye!")
				write(conn, "\n")
				close(conn)
				break
			end
		end
	catch err
		# Something goes wrong and client socket is not available anymore
		println("Somethin goes wrong. Error msg: $err")
	end
end
end