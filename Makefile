#
# Docker helper
#

no_cache=false

# Build Docker image
build:
	sudo docker build --no-cache=$(no_cache) -t="obiba/opal-rserver:snapshot" .

run:
	sudo docker run -d -p 6612:6312 -p 6611:6311 --name rserver obiba/opal-rserver:snapshot