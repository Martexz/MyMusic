const Admin = require('./admin');
const Consumer = require('./consumer');
const Singer = require('./singer');
const Song = require('./song');
const SongList = require('./song_list');
const ListSong = require('./list_song');
const Collect = require('./collect');
const Comment = require('./comment');
const Rank = require('./rank');
const Swiper = require('./swiper');
const sequelize = require('../config/db');

// 关联关系
Song.belongsTo(Singer, { foreignKey: 'singer_id', as: 'singer' });
ListSong.belongsTo(SongList, { foreignKey: 'song_list_id', as: 'songList' });
ListSong.belongsTo(Song, { foreignKey: 'song_id', as: 'song' });
Collect.belongsTo(Consumer, { foreignKey: 'consumer_id', as: 'consumer' });
Collect.belongsTo(Song, { foreignKey: 'song_id', as: 'song' });
Collect.belongsTo(SongList, { foreignKey: 'song_list_id', as: 'songList' });
Comment.belongsTo(Consumer, { foreignKey: 'consumer_id', as: 'consumer' });
Comment.belongsTo(Song, { foreignKey: 'song_id', as: 'song' });
Comment.belongsTo(SongList, { foreignKey: 'song_list_id', as: 'songList' });
Rank.belongsTo(Consumer, { foreignKey: 'consumer_id', as: 'consumer' });
Rank.belongsTo(SongList, { foreignKey: 'song_list_id', as: 'songList' });

sequelize.sync();

module.exports = {
  Admin,
  Consumer,
  Singer,
  Song,
  SongList,
  ListSong,
  Collect,
  Comment,
  Rank,
  Swiper
};

