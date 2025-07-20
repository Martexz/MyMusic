const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const Comment = sequelize.define('Comment', {
  id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  consumer_id: { type: DataTypes.INTEGER, allowNull: false },
  song_id: { type: DataTypes.INTEGER, allowNull: true },
  song_list_id: { type: DataTypes.INTEGER, allowNull: true },
  content: { type: DataTypes.TEXT, allowNull: false },
  created_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW }
}, {
  tableName: 'comments',
  timestamps: false
});

module.exports = Comment;
