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
	
	# Configure Boid directories
	boidFile := method(File with("boid.io"))
	boidDir := method(Directory with(User homeDirectory path .. "/.boid"))
	ioDir := method(Directory with(boidDir path .. "/active/io"))
	binDir := method(Directory with(boidDir path .. "/active/bin"))
	
	# Select appropriate startup script template based on user's shell
	# Thanks to rip for a good jumping-off point
	shStartupScripts := list(".bash_profile", ".bash_login", ".bashrc", ".zshenv", ".profile", ".zshrc")
	fishStartupScript := ".config/fish/config.fish"
	fish := method(File with(User homeDirectory path .. "/" .. fishStartupScript) exists)
	startupScript := File openForAppending(User homeDirectory path .. "/" .. if(fish, fishStartupScript, shStartupScripts select(s, File with(User homeDirectory path .. "/" .. s) exists) first))

	template := if(fish, fishTemplate, shTemplate)
	template = template interpolate
	
	"% boid setup" println
	
	if (Directory exists(boidDir path),
		abort("previous install detected in `#{boidDir path}'" interpolate)
	)
	
	# Create necessary directories, if required
	"% creating directories:" println
	"  - #{boidDir path}" interpolate println
	Directory setCurrentWorkingDirectory(boidDir parentDirectory path)
	Directory createSubdirectory(boidDir name)
	if(boidDir exists not, abort("failed to create .boid directory"))
	baseDir := Directory with(boidDir path .. "/base")
	baseDir create
	Directory createSubdirectory(boidDir name .. "/base/io")
	"""  - #{boidDir path .. "/base/io"}""" interpolate println
	if(Directory with(boidDir path .. "/base/io") exists not, abort("failed to create #{boidDir path}/base/io directory" interpolate))
	Directory createSubdirectory(boidDir name .. "/base/bin")
	"""  - #{boidDir path .. "/base/bin"}""" interpolate println
	if(Directory with(boidDir path .. "/base/bin") exists not, abort("failed to create #{boidDir path}/base/bin directory" interpolate))
	
	# Create the necessary symbolic links
	"% activating base environment" println
	"ln -s #{baseDir path} #{boidDir path}/active" interpolate println
	cmd := System runCommand("ln -s #{baseDir path} #{boidDir path}/active" interpolate)
	if(cmd exitStatus > 0, abort("failed to create symlink to active environment:\n  #{cmd stderr}" interpolate))
	File with(baseDir path .. "/.active") create
	
	# Modify the user's startup script
	"% modifying your startup script" println
	"  - #{startupScript path}" interpolate println
	startupScript write(template interpolate) close
	
	# Finish up
	"% success!" println
	"  restart your shell to finish up the process" println
	
	
)
