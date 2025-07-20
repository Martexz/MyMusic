const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const Swiper = sequelize.define('Swiper', {
  id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  pic: { type: DataTypes.STRING(255), allowNull: false },
  url: { type: DataTypes.STRING(255) },
  title: { type: DataTypes.STRING(100) },
  created_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW }
}, {
  tableName: 'swipers',
  timestamps: false
});

module.exports = Swiper;
