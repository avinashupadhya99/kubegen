FROM node:16.19.1-bullseye-slim

WORKDIR /app

COPY ["package.json", "package-lock.json*", "./"]

RUN npm install

COPY . .

CMD [ "npm", "start" ]