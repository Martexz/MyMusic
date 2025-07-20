const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const ListSong = sequelize.define('ListSong', {
  id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  song_list_id: { type: DataTypes.INTEGER, allowNull: false },
  song_id: { type: DataTypes.INTEGER, allowNull: false },
  created_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW }
}, {
  tableName: 'list_songs',
  timestamps: false
});

module.exports = ListSong;
