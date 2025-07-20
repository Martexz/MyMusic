const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const Rank = sequelize.define('Rank', {
  id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  consumer_id: { type: DataTypes.INTEGER, allowNull: false },
  song_list_id: { type: DataTypes.INTEGER, allowNull: false },
  score: { type: DataTypes.INTEGER, allowNull: false, validate: { min: 1, max: 10 } },
  created_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW }
}, {
  tableName: 'ranks',
  timestamps: false
});

module.exports = Rank;
