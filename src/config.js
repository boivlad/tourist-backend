export const app = {
  "port": 3000,
  "jwt": {
    secret: 'SecretKeyForAuth',
    tokens: {
      access: {
        type: 'access',
        expiresIn: '2m',
      },

      refresh: {
        type: 'refresh',
        expiresIn: '3m',
      },
    },
  },
  "database": {
    "roles": {
      "client": {
        "password": "client"
      },
      "manager": {
        "password": "manager"
      },
      "director": {
        "password": "director"
      },
      "postgres": {
        "password": "1111"
      },
      "anonymous": {
        "password": "1111"
      }
    },
    "database": "tourist1",
    "host": "localhost",
    "port": "5432"
  }
};
