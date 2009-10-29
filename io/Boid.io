#!/usr/bin/env io

BoidException := Exception clone

boidDir = System getEnvironmentVariable("BOIDDIR")
ifNil(boidDir, BoidException raise("BOIDDIR variable not set"))
