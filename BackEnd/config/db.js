const { Sequelize } = require('sequelize');

const sequelize = new Sequelize('music_app', 'root', '123456', {
  host: 'localhost',
  dialect: 'mysql',
  logging: false,
  define: {
    freezeTableName: true,
    timestamps: false
  }
});

module.exports = sequelize;
