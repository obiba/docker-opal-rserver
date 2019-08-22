#
# Docker helper
#

no_cache=false

# Build Docker image
build:
	sudo docker build --no-cache=$(no_cache) -t="obiba/opal-rserver:snapshot" .

build-version:
	sudo docker build --no-cache=$(no_cache) -t="obiba/opal-rserver:$(version)" $(version)

run:
	sudo docker run -d -p 6312:6312 -p 6311:6311 -p 53000-53100:53000-53100 --name rserver obiba/opal-rserver:snapshot
