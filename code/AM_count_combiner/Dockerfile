# Use node, version 14 so that we get worker threads
FROM mhart/alpine-node:14

# Create app directory
WORKDIR /usr/src/app

# Copy everything else over to docker image
COPY ./*.js ./

CMD [ "node", "merge3.js" ]