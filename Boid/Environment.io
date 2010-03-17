# A Boid environment is a collection of individual packages. There can only
# be one version of a package installed in an environment, but Boid allows you
# to maintain multiple environments and activate different ones as needed,
# which allows you to have multiple non-conflicting versions of the same
# package installed on your system.

# The `Boid Environment` object is actually the environment manager.
Boid Environment := Object clone do(

	# Each environment has its own directory within Boid's directory.
	# This method returns a `List` of `Directory` objects for all of the
	# environment directories, except for the symlink to the active environment.
	#
	# Environment directories have this structure:
	#
	#     environment_name/
	#       bin/
	#       io/
	#
	# The **bin/** directory is where executable files go, and the **io/**
	# directory is where Io source files go. The **active** symlink in the
	# Boid directory points to the active environment's directory, and the
	# Boid setup script adds **~/.boid/active/bin** to your `PATH` and
	# **~/boid/active/io** to your `IOIMPORT`.
	directories := method(
		Directory with(Boid boidDir path) directories select(d, d name != "active"))

	# A new environment is created by creating a new directory in the Boid
	# directory. Then, the **bin/** and **io/** files are created in the
	# directory of the newly created environment.
	create := method(envName,
		env := Directory with(Boid boidDir path .. "/" .. envName)
		if(env exists,
			BoidError raise("#{envName} environment already exists" interpolate))
		env create
		if(env exists not,
			BoidError raise("could not create #{envName} environment" interpolate))
		Directory with(env path .. "/bin") create
		Directory with(env path .. "/io") create)
	
	# To destroy an environment, all that needs to happen is the erasure of
	# its directory. Destroying the active environment is not permitted.
	destroy := method(envName,
		env := Directory with(Boid boidDir path .. "/" .. envName)
		if(env exists not,
			BoidError raise("#{envName} environment does not exist" interpolate))
		if(env at(".active"),
			BoidError raise("can not destroy the active environment"))
		if(System runCommand("rm -rf #{env path}" interpolate) exitStatus > 0,
			BoidError raise("could not destroy #{envName} environment" interpolate)))

	# A `Directory` object for the active environment is returned by the
	# `active` method.
	active := method(Directory with(Boid boidDir path .. "/active"))
	
	# Switching the active environment is a little trickier. The active
	# environment also has a file called **.active** placed in it, so that the
	# name of the active environment can be found.
	use := method(envName,
		env := Directory with(Boid boidDir path .. "/" .. envName)
		if(env exists not,
			BoidError raise("#{envName} environment does not exist" interpolate))
		# First the **.active** file needs to be removed.
		File with(active path .. "/.active") remove
		# Then the symlink to the active environment is removed.
		active remove
		if(active exists,
			BoidError raise("could not remove symbolic link to active environment"))
		# Finally, a new symlink is created to the new active environment.
		if(System runCommand("ln -s #{env path} #{active path}" interpolate) exitStatus > 0,
			BoidError raise("could not create symbolic link to active environment"))
		File with(active path .. "/.active") create))
		
