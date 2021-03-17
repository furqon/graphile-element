require('dotenv').config();

const express = require('express'),
  { postgraphile } = require('postgraphile');

const app = express();

// POSTGRAPHILE
const postgresConfig = {
  user: process.env.POSTGRES_USERNAME,
  password: process.env.POSTGRES_PASSWORD,
  host: process.env.POSTGRES_HOST,
  port: process.env.POSTGRES_PORT,
  database: process.env.POSTGRES_DATABASE
};
const postgraphileOptions = {
  subscriptions: true,
  graphiql: true,
  enableCors: true,
  watchPg: true,
  dynamicJson: true,
  setofFunctionsContainNulls: false,
  ignoreRBAC: false,
  ignoreIndexes: false,
  showErrorStack: 'json',
  extendedErrors: ['hint', 'detail', 'errcode'],
  jwtPgTypeIdentifier: `${process.env.POSTGRAPHILE_SCHEMA}.jwt`,
  jwtSecret: process.env.JWT_SECRET,
  ownerConnectionString: 'auth',
  appendPlugins: [],
  enhanceGraphiql: true,
  allowExplain(req) {
    // TODO: customise condition!
    return true;
  },
  enableQueryBatching: true,
  legacyRelations: 'omit',
  pgSettings(req) {
    /* TODO */
  },
};
app.use(postgraphile(
  postgresConfig,
  process.env.POSTGRAPHILE_SCHEMA, 
  postgraphileOptions
));
// END POSTGRAPHILE

app.listen(process.env.APP_PORT, () => {
  console.log(`Server listening on port ${process.env.APP_PORT}.`);
});