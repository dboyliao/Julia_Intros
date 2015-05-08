module MyModule

export x, y, z

x() = "x"
y() = "y"
p() = "p"

function __init__()
	println("Hello!")
	global z = "I'm z."
end

end