export const app = {
  port: 8080,
  jwt: {
    secret: 'SecretKeyForAuth',
    tokens: {
      access: {
        type: 'access',
        expiresIn: '1h',
      },
    },
  },
  database: {
    roles: {
      client: {
        password: 'client',
      },
      manager: {
        password: 'manager',
      },
      director: {
        password: 'director',
      },
      postgres: {
        password: '1111',
      },
      anonymous: {
        password: '1111',
      },
    },
    database: 'tourist1',
    host: 'localhost',
    port: '5432',
  },
};
