Boid Package := Object clone

Boid Package do(

	name := nil
	source := nil
	
	setName := method(newName, self name = newName; self)
	
	setSource := method(newSource, self source = newSource; self)
	
	install := method(
		Boid fail("packages of this type cannot yet be installed"))
	
	uninstall := method(
		Boid fail("packages of this type cannot yet be uninstalled")))

Boid Package Git := Object clone

Boid Package Git do(

	install := method(
		nil))
