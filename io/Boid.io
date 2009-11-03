BoidError := Exception clone
Boid := Object clone
Boid Environment := Object clone
Boid Package := Object clone

Boid do(

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

	/* Returns a list of directory objects for each environment */
	directories := method(
		Directory with(Boid boidDir path) directories select(d, d name != "active")
	)

	/* Creates a new environment */
	create := method(envName,
		env := Directory with(Boid boidDir path .. "/" .. envName)
		if(env exists, BoidError raise("#{envName} environment already exists" interpolate))
		env create
		if(env exists not, BoidError raise("could not create #{envName} environment" interpolate))
		Directory with(env path .. "/bin") create
		Directory with(env path .. "/io") create
	)
	
	/* Destroys a given environment. Can't be the active environment. */
	destroy := method(envName,
		env := Directory with(Boid boidDir path .. "/" .. envName)
		if(env exists not, BoidError raise("#{envName} environment does not exist" interpolate))
		if(env at(".active"), BoidError raise("can not destroy the active environment"))
		System system("rm -rf #{env path}" interpolate)
		env remove
		if(env exists, BoidError raise("could not destroy #{envName} environment" interpolate))
	)
	
	/* Returns a list of environment names */
	list := method(directories map(name))
	
	/* Returns a Directory object of the current active environment's directory */
	active := method(Directory with(Boid boidDir path .. "/active"))
	
	/* Switches the current active environment */
	use := method(envName,
		env := Directory with(Boid boidDir path .. "/" .. envName)
		if(env exists not, BoidError raise("#{envName} environment does not exist" interpolate))
		File with(active path .. "/.active") remove
		active remove
		if(active exists, BoidError raise("could not remove symbolic link to active environment"))
		System system("ln -s #{env path} #{active path}" interpolate)
		if(active exists not, BoidError raise("Could not create symbolic link to active environment"))
		File with(active path .. "/.active") create
	)
	
)
