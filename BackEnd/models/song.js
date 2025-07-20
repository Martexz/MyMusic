const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const Song = sequelize.define('Song', {
  id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  name: { type: DataTypes.STRING(100), allowNull: false },
  singer_id: { type: DataTypes.INTEGER, allowNull: true },
  url: { type: DataTypes.STRING(255), allowNull: false },
  pic: { type: DataTypes.STRING(255) },
  lyric: { type: DataTypes.TEXT },
  created_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW }
}, {
  tableName: 'songs',
  timestamps: false
});

module.exports = Song;
