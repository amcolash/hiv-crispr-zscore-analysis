# Use node v18
FROM node:18-alpine

# Create app directory
WORKDIR /usr/src/app

# Copy code over to docker image
COPY ./*.js ./

CMD [ "node", "cols.js" ]