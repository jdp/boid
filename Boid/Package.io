# A Boid environment is a collection of *packages*. Eventually installable
# packages will include single Io source files, directories, and version control
# system checkouts.

# The `Boid Package` object shows the minimum structure of descendant package
# protos.
Boid Package := Object clone do(
	
	# The `canHandle` method returns a boolean whether or not the package
	# can handle a certain package spec.
	canHandle := method(spec, false)
	
	# The `install` method attempts to install the package according to its
	# specification. A `BoidError` should be raised whenever a problem occurs,
	# `Boid fail` should not be called directly.
	install := method(
		BoidError raise("packages of this type cannot yet be installed"))
	
	# Surprisingly, the `uninstall` method uninstalls a package.
	uninstall := method(
		BoidError raise("packages of this type cannot yet be uninstalled")))

# Boid can install single-file packages, as long as they end with the .io
# file extension.
Boid FilePackage := Boid Package clone do(
	
	canHandle := method(spec,
		spec matchesRegex("^.*\.io$"))
	
	validates := method(spec,
		File with(spec) exists)
	
	isInstalled := method(spec,
		localFile := File with(spec)
		File with(Boid ioDir path .. "/" .. localFile name) exists)
	
	# Installation of a single-file package is pretty straightforward.
	install := method(spec,
		# The `FilePackage` object makes sure it recognizes the package spec
		# it was given, and makes sure the file being installed actually
		# exists and was not installed already.
		if(canHandle(spec) not,
			BoidError raise("`#{spec}' isn't recognized by #{type}" interpolate))
		if(validates(spec) not,
			BoidError raise("`#{spec}' does not exist" interpolate))
		if(isInstalled(spec),
			BoidError raise("`#{spec}' is already installed" interpolate))
		# If everything goes well the Io source file is copied to the **io/**
		# directory in the active environment and the original source file
		# is left where it is.
		localFile := File with(spec)
		pkgFile := File with(Boid ioDir path .. "/" .. localFile name)
		localFile copyToPath(pkgFile path)
		if(pkgFile exists not,
			BoidError raise("addition of `#{localFile name}' to active environment failed" interpolate))
		true)
	
	# When a single source file package is removed, it is just a matter of
	# deleting the file from the **io/** directory in the active environment.
	uninstall := method(spec,
		if(canHandle(spec) not,
			BoidError raise("`#{spec}' isn't recognized by #{type}" interpolate))
		if(isInstalled(spec) not,
			BoidError raise("`#{spec}' is not installed" interpolate))
		localFile := File with(spec)
		pkgFile := File with(Boid ioDir path .. "/" .. localFile name)
		pkgFile remove
		if(pkgFile exists,
			BoidError raise("removal of `#{localFile name}' from active environment failed" interpolate))
		true))

# Available package handlers are kept in a list, ordered by priority from
# highest to lowest. Only the `FilePackage` single-file package handler is
# available currently.
Boid Package handlers := list(Boid FilePackage)
