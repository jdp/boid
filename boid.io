#!/usr/bin/env io

Importer addSearchPath("Boid")

Boid
BoidError
Range

opts := System args
opts removeFirst
opts first switch(
	nil,
		"boid -h" println,
	"check",
		envBoidDir := System getEnvironmentVariable("BOIDDIR")
		if(envBoidDir isNil,
			Boid fail("BOIDDIR environment variable not set"),
			"BOIDDIR=#{envBoidDir}" interpolate println)
		envIoImport := System getEnvironmentVariable("IOIMPORT")
		if(envIoImport isNil,
			Boid fail("IOIMPORT environment variable not set"),
			"IOIMPORT=#{envIoImport}" interpolate println)
		if(envIoImport split(":") contains(Boid ioDir path) not,
			Boid fail("`#{Boid ioDir path}' not in IOIMPORT"))
		if(System getEnvironmentVariable("PATH") split(":") contains(Boid binDir path) not,
			Boid fail("`#{Boid binDir path}' not in PATH"))
		if(Boid check not,
			Boid fail("invalid setup, please run setup.io again"))
		"ok" println,
	"install",
		packageSpec := opts second
		if(packageSpec isNil, Boid fail("no package spec provided"))
		e := try(Boid install(packageSpec))
		e catch(BoidError, Boid fail("install failed: #{e error}" interpolate))
		"package #{packageSpec} installed" interpolate println,
	"uninstall",
		packageSpec := opts second
		if(packageSpec isNil, Boid fail("no package spec provided"))
		e := try(Boid uninstall(packageSpec))
		e catch(BoidError, Boid fail("uninstall failed: #{e error}" interpolate))
		"package #{packageSpec} uninstalled" interpolate println,
	"list",
		Boid listPackages,
	"env",
		envCmd := opts second
		if(envCmd isNil, envCmd = "list")
		envCmd switch(
			"list",
				Boid Environment directories foreach(d,
					if(d at(".active"), "* " print)
					d name println),
			"active",
				Boid Environment directories select(d, d at(".active")) first name println,
			"use",
				envName := opts third
				if(envName isNil, Boid fail("no environment name provided"))
				e := try(Boid Environment use(envName))
				e catch(BoidError, Boid fail(e error))
				"switched environment to #{envName}" interpolate println,
			"create",
				envName := opts third
				if(envName isNil, Boid fail("no environment name provided"))
				e := try(Boid Environment create(envName))
				e catch(BoidError, Boid fail(e error))
				"#{envName} environment created" interpolate println,
			"destroy",
				envName := opts third
				if(envName isNil, Boid fail("no environment name provided"))
				e := try(Boid Environment destroy(envName))
				e catch(BoidError, Boid fail(e error))
				"#{envName} environment destroyed" interpolate println))

Boid cleanup
