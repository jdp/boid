BoidException := Exception clone

Boid := Object clone do(

	orient := method(
		self boidDir := System getEnvironmentVariable("BOIDDIR")
		self boidDir ifNil(fail("BOIDDIR environment variable not set"))
		Directory with(boidDir) exists ifFalse(fail("`#{boidDir}' does not exist" interpolate))
		self binDir := boidDir .. "/active/bin"
		Directory with(binDir) exists ifFalse(fail("`#{binDir}' does not exist" interpolate))
		self ioDir := boidDir .. "/active/io"
		Directory with(ioDir) exists ifFalse(fail("`#{ioDir}' does not exist" interpolate))
	)
	
	publicize := method(
		Importer addSearchPath(ioDir)
	)
	
	installPackage := method()
	
	uninstallPackage := method()
	
	listPackages := method()
	
	createEnvironment := method()
	
	destroyEnvironment := method()
	
	listEnvironments := method()
	
	activeEnvironment := method()
	
	fail := method(msg,
		"boid: #{msg}" interpolate println
		System exit(1)
	)
	
	check := method(
		"Boid operational. Let's party." println
	)
	
	startup := method(
		orient
		publicize
	)
	
)
