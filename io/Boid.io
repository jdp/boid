BoidException := Exception clone
Boid := Object clone
Boid Environment := Object clone
Boid Package := Object clone

Boid do(

	//doc 
	boidDir := method(
		boidDirEnv := System getEnvironmentVariable("BOIDDIR")
		boidDirEnv ifNil(fail("BOIDDIR environment variable not set"))
		Directory with(boidDirEnv)
	)
	binDir := method(Directory with(boidDir path .. "/active/bin"))
	ioDir := method(Directory with(boidDir path .. "/active/io"))

	check := method(
		if(boidDir exists not, return(false))
		if(binDir exists not, return(false))
		if(ioDir exists not, return(false))
		true
	)
	
	fail := method(msg,
		"boid: #{msg}" interpolate println
		System exit(1)
	)
	
)

Boid Environment do(

	create := method(envName,
		env := Directory with(Boid boidDir path .. "/" .. envName)
		if(env exists, BoidException raise("#{envName} environment already exists" interpolate))
		env create
		if(env exists not, BoidException raise("could not create #{envName} environment" interpolate))
	)
	
	destroy := method(envName
		env := Directory with(Boid boidDir path .. "/" .. envName)
		if(env exists not, BoidException raise("#{envName} environment does not exist" interpolate))
		env remove
		if(env exists, BoidException raise("could not destroy #{envName} environment" interpolate))
	)
	
	list := method()
	
	active := method(Directory with(Boid boidDir path .. "/active"))
	
	use := method(envName,
		env := Directory with(Boid boidDir path .. "/" .. envName)
		if(env exists not, BoidException raise("#{envName} environment does not exist" interpolate))
		active remove
		if(active exists, BoidException raise("could not remove symbolic link to active environment"))
		System system("ln -s #{env path} #{active path}" interpolate)
		if(active exists not, BoidException raise("Could not create symbolic link to active environment"))
	)
	
	directories := method(
		Directory with(boidDir path) directories select(d, (d fileNamed("env.io") exists) and (d name != "active"))
	)
	
)
