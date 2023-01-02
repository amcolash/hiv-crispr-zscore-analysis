# Use node v18
FROM node:18-alpine

# Create app directory
WORKDIR /usr/src/app

# Copy everything else over to docker image
COPY ./*.js ./

CMD [ "node", "merge3.js" ]