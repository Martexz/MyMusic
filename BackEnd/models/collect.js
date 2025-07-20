const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const Collect = sequelize.define('Collect', {
  id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  consumer_id: { type: DataTypes.INTEGER, allowNull: false },
  song_id: { type: DataTypes.INTEGER, allowNull: true },
  song_list_id: { type: DataTypes.INTEGER, allowNull: true },
  created_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW }
}, {
  tableName: 'collects',
  timestamps: false
});

module.exports = Collect;
