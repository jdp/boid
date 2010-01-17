# Basically all of this was converted from Ruby to Io, the source
# being the Rip project.
# http://hellorip.com
 
Git := Object clone

Git do(

	lsRemote := method(source, version = nil,
		System runCommand("git ls-remote #{source} #{version}" interpolate))
	
	klone := method(source, cacheName,
		System runCommand("git clone #{source} #{cacheName}" interpolate))
	
	fetch := method(remote,
		System runCommand("git fetch #{remote}" interpolate))
	
	resetHard := method(version,
		System runCommand("git reset --hard #{version}" interpolate))
	
	submoduleInit := method(
		System runCommand("git submodule init"))
	
	submoduleUpdate := method(
		System runCommand("git submodule update"))
	
	revParse := method(obj,
		System runCommand("git rev-parse #{obj}" interpolate))
		
	catFile := method(obj,
		System runCommand("git cat-file -p #{obj}")))
		
