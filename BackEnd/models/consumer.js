const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const Consumer = sequelize.define('Consumer', {
  id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  username: { type: DataTypes.STRING(50), unique: true, allowNull: false },
  password: { type: DataTypes.STRING(100), allowNull: false },
  email: { type: DataTypes.STRING(100) },
  avatar: { type: DataTypes.STRING(255) },
  created_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW }
}, {
  tableName: 'consumers',
  timestamps: false
});

module.exports = Consumer;
