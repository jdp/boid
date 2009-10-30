#!/usr/bin/env io

BoidSetup := Object clone

BoidSetup fishTemplate := """
# Start Boid configuration
set -x BOIDDIR #{boidDir path}
set -x IOIMPORT $IOIMPORT $BOIDDIR/active/io
set PATH $PATH $BOIDDIR/active/bin
# End Boid configuration"""

BoidSetup shTemplate := """
# Start Boid configuration
BOIDDIR=#{boidDir path}
IOIMPORT="$IOIMPORT:$BOIDDIR/active/lib"
PATH="$PATH:$BOIDDIR/active/bin"
export BOIDDIR IOIMPORT PATH
# End Boid configuration"""

BoidSetup do(
	
	abort := method(msg,
		"% setup aborted:" println
		"  #{msg}" interpolate println
		System exit(1)
	)
	
	boidDir := method(Directory with(User homeDirectory path .. "/.boid"))
	ioDir := method(Directory with(boidDir path .. "/active/io"))
	binDir := method(Directory with(boidDir path .. "/active/bin"))
	
	shStartupScripts := list(".bash_profile", ".bash_login", ".bashrc", ".zshenv", ".profile", ".zshrc")
	fishStartupScript := ".config/fish/config.fish"
	fish := method(File with(User homeDirectory path .. "/" .. fishStartupScript) exists)
	startupScript := File openForAppending(User homeDirectory path .. "/" .. if(fish, fishStartupScript, shStartupScripts select(s, File with(User homeDirectory path .. "/" .. s) exists) first))

	template := if(fish, fishTemplate, shTemplate)
	template = template interpolate
	
	"% boid setup" println
	
	"% creating directories:" println
	"  - #{boidDir path}" interpolate println
	Directory setCurrentWorkingDirectory(boidDir parentDirectory path)
	Directory createSubdirectory(boidDir name)
	if(boidDir exists not, abort("failed to create .boid directory"))
	Directory createSubdirectory(boidDir name .. "/base")
	Directory createSubdirectory(boidDir name .. "/base/io")
	"""  - #{boidDir path .. "/base/io"}""" interpolate println
	if(Directory with(boidDir path .. "/base/io") exists not, abort("failed to create #{boidDir path}/base/io directory" interpolate))
	Directory createSubdirectory(boidDir name .. "/base/bin")
	"""  - #{boidDir path .. "/base/bin"}""" interpolate println
	if(Directory with(boidDir path .. "/base/bin") exists not, abort("failed to create #{boidDir path}/base/bin directory" interpolate))
	
	"% activating base environment" println
	System system("""ln -sf #{boidDir path .. "/base"} #{boidDir name}/active > /dev/null""" interpolate)
	
	"% modifying your startup script" println
	"  - #{startupScript path}" interpolate println
	startupScript write(template interpolate) close
	
)
