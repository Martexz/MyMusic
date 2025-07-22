const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const SongList = sequelize.define('SongList', {
  id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  title: { type: DataTypes.STRING(100), allowNull: false },
  style: { type: DataTypes.STRING(50) },
  pic: { type: DataTypes.STRING(255) },
  introduction: { type: DataTypes.TEXT },
  created_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
  user_id: { type: DataTypes.INTEGER, allowNull: true,defaultValue:null }
}, {
  tableName: 'song_lists',
  timestamps: false
});

module.exports = SongList;
