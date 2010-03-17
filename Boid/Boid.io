### Boid

# Boid is a package manager for the [Io language][io], modeled after
# tools like [Rip][rip] and [virtualenv][ve]. Its main goal is to allow
# programmers to maintain individual *environments* in which packages can be
# installed, even different versions of the same package. To prevent
# inconsistencies, only one environment can be active at a time and can only
# have one version of a package in it.
#
# Boid tries to be flexible in what is considered a *package*. Files,
# directories, and version control system checkouts can all be considered
# packages by Boid.
#
# When Boid is installed, it creates a **~/.boid** directory for the user who
# installed it. Every environment is stored within it as its own directory,
# with a symlink called **active** pointing to the directory of the active
# environment.
#
# The Boid directory structure looks like this when it is installed:
#
#    .boid/
#      active@
#      base/
#        bin/
#        io/
#
# The **base/** directory is the environment created by default, and starts as
# the active directory. For information about the directory structure of
# environments, check out the [environment annotations][ea].
#
# [io]: http://iolanguage.com
# [rip]: http://hellorip.com
# [ve]: http://pypi.python.org/pypi/virtualenv
# [ea]: Environment.html

#### Imports

# Io is a strange creature, some objects need to be referenced before they can
# be used in the script. 
Regex

# A specialized `Exception` object is used by Boid when exceptions are thrown.
BoidError := Exception clone

#### The Meat of it All

# The Boid object acts as a dispatcher. Calls to `install` and `uninstall` are
# delegated to other objects to actually do all the work.
Boid := Object clone do(

	# The `boidDir` method returns a `Directory` object with the path
	# contained in the `BOIDDIR` environment variable. The setup script by
	# default will set `BOIDDIR` to `~/.boid`.
	boidDir := method(
		boidDirEnv := System getEnvironmentVariable("BOIDDIR")
		boidDirEnv ifNil(fail("BOIDDIR environment variable not set"))
		Directory with(boidDirEnv))
		
	# This returns a `Directory` object that points to the binary directory
	# of the active package. Normally it will be **~/.boid/active/bin**, where
	# **active** is actually a symbolic link to the directory of the current
	# environment.
	binDir := method(Directory with(boidDir path .. "/active/bin"))
	
	# This `Directory` object that points to the Io source directory of the
	# active environment, which is what is reflected in the `IOIMPORT`
	# environment variable.
	ioDir := method(Directory with(boidDir path .. "/active/io"))

	# Checks whether or not the `boidDir`, `binDir`, and `ioDir` paths exist.
	check := method(
		list(boidDir, binDir, ioDir) map(d, d exists) reduce(a, b, a and b))
	
	# Package installation is done by package handlers, which are separate
	# objects for each type of package that can be installed. The first handler
	# that recoginizes the package specification is used to try to install the
	# package.
	install := method(source,
		handler := Package handlers select(h, h canHandle(source)) first clone
		handler ifNil(
			BoidError raise("could not find appropriate package handler"))
		handler install(source))
		
	# Package uninstallation is also done by package handlers.
	uninstall := method(source,
		handler := Package handlers select(h, h canHandle(source)) first clone
		handler ifNil(
			BoidError raise("could not find appropriate package handler"))
		handler uninstall(source))
	
	# Io's `System runCommand` method leaves behind files from `stdout` and
	# `stderr` every time it is run, we have to clean them up so the user's
	# home directory doesn't get filled with garbage.
	cleanup := method(
		System system("rm -rf *-stdout")
		System system("rm -rf *-stderr"))
	
	# General failure handler. If anything fails for any reason, this method is
	# called and boid is terminated, along with the shell status code being set
	# to 1.
	fail := method(msg,
		"boid: #{msg}" interpolate println
		System exit(1)))

# Include all the other source files to get the party started.
doRelativeFile("Git.io")
doRelativeFile("Environment.io")
doRelativeFile("Package.io")

