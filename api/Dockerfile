FROM node:16-slim

WORKDIR /app

ENV NODE_PATH ./dist

COPY package*.json ./

RUN npm install

COPY . ./

RUN npm run build

CMD [ "npm", "start" ]