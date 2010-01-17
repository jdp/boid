Boid := Object clone

sh := method(cmd,
	System runCommand(cmd))

cond := method(
	if(call argCount < 2, Exception raise("at least one condition and clause required"))
	args := 0 to(call argCount - 1) map(i, call argAt(i))
	default := if(call argCount % 2 == 1, args removeLast, nil)
	conds := args select(i, v, i % 2 == 0)
	results := args select(i, v, i % 2 == 1)
	conds foreach(i, cond,
		cond doInContext(call sender, call slotContext) ifTrue(return(results at(i) doInContext(call sender, call slotContext)))
	)
	default doInContext(call sender, call slotContext)
)

Boid do(

	# path to the boid directory
	# usually of the format /home/user/.boid
	boidDir := method(
		boidDirEnv := System getEnvironmentVariable("BOIDDIR")
		boidDirEnv ifNil(fail("BOIDDIR environment variable not set"))
		Directory with(boidDirEnv))
		
	# path to the directory for binaries included in boid packages
	binDir := method(Directory with(boidDir path .. "/active/bin"))
	
	# path to the directory for boid package sources
	ioDir := method(Directory with(boidDir path .. "/active/io"))

	# returns boolean as to whether or not all the paths exist
	check := method(
		cond(
			boidDir exists not, false,
			binDir exists not, false,
			ioDir exists not, false,
			true))
	
	# shows a failure message and sets the status code to 1
	fail := method(msg,
		"boid: #{msg}" interpolate println
		System exit(1)))

doRelativeFile("Git.io")
doRelativeFile("Environment.io")
doRelativeFile("Package.io")

Git klone("git://github.com/jdp/io-scgi.git", "io-scgi-453453453")

