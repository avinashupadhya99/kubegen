package main

import (
	"dagger.io/dagger"
	"dagger.io/dagger/core"
	"universe.dagger.io/bash"
	"universe.dagger.io/docker"
)

dagger.#Plan & {
    client: {
        filesystem: ".": {
            read: {
                contents: dagger.#FS
            }
        }
        env: {
            DOCKER_HUB_USERNAME: string
            DOCKER_HUB_PASSWORD: dagger.#Secret,
            BUILD_NUMBER: string
        }
    }
	actions: {
		build: {
			// core.#Source lets you access a file system tree (dagger.#FS)
			// using a path at "." or deeper (e.g. "./foo" or "./foo/bar") with
			// optional include/exclude of specific files/directories/globs
			checkoutCode: core.#Source & {
				path: "."
			}
			// Pulls from Docker Hub by default, but you can set registry/auth
			// Choosing an image with yarn/npm and bash already installed
			pull: docker.#Pull & {
				source: "node:lts"
			}
			// Copies content into input container's filesystem (at "/" by default)
			copy: docker.#Copy & {
				input:    pull.output
				contents: checkoutCode.output
			}
			// Runs a bash script in the input container
			// in this case npm install (or npm ci, if you prefer)
			install: bash.#Run & {
				input: copy.output
				script: contents: """
					npm install
					# npm ci
					"""
			}
			// Runs a bash script in the input container
			// in this case, scripts in my package.json
			buildTest: bash.#Run & {
				input: install.output
				script: contents: """
					npm run build
					npm run test
					"""
			}

            dockerBuild: docker.#Dockerfile & {
                // This is the Dockerfile context
                source: client.filesystem.".".read.contents
                label: HACK: "\(buildTest.success)" // <== HACK: CHAINING of action. Esnures the action is executed after buildTest is completed
            }

            push: docker.#Push & {
                auth: {
                    username: client.env.DOCKER_HUB_USERNAME
                    secret: client.env.DOCKER_HUB_PASSWORD
                }
                image: dockerBuild.output
                dest: "avinashupadhya99/kubegen:1.0.0-\( client.env.BUILD_NUMBER )"
            }
		}
	}
}