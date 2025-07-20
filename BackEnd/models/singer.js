const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const Singer = sequelize.define('Singer', {
  id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  name: { type: DataTypes.STRING(100), allowNull: false },
  gender: { type: DataTypes.ENUM('男','女','组合','未知'), defaultValue: '未知' },
  pic: { type: DataTypes.STRING(255) },
  description: { type: DataTypes.TEXT },
  created_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW }
}, {
  tableName: 'singers',
  timestamps: false
});

module.exports = Singer;
