# graphile-element

This is sample of admin [vue-element-admin](https://github.com/PanJiaChen/vue-element-admin) using [postgraphile](https://www.graphile.org/) as backend instead of mockup. Only part of login that using graphile, the rest is left for your exercises :)

For this purpose, I only request query without using any mutations. Postgraphile can saves you a lot of time in doing backend chores. All graphql request is using [vue-apollo](https://apollo.vuejs.org/).

## Installation

Clone this repo
```sh
git clone https://github.com/furqon/graphile-element.git
cd graphile-element
```
### Backend
before seting up backend, you have to install database in postgresql and setup the .env (edit as you setup db). Im using yarn, you can use npm.
```sh
cd server
cp .env.example .env
yarn install
```
get the database schema to your db
```sh
psql yourdb < provision.sql
```
start the server 
```sh
yarn start
```
You can play the server by accessing http://localhost:5000/graphiql

### Frontend / Client
```sh
cd client
yarn install
yarn dev
```
You can test to login using username: admin@mail.com password: admin

## Thank You
| apps | site |
| ------ | ------ |
| postgraphile | [https://www.graphile.org/]|
| vue-element-admin | [https://github.com/PanJiaChen/vue-element-admin] |
| element-ui | [https://element.eleme.io/#/en-US] |
| vue-apollo | [https://apollo.vuejs.org/] |

### resources
a very very good video from [@benjie](https://github.com/benjie) about postgrapile (https://www.youtube.com/watch?v=eDZO8z1qw3k)

