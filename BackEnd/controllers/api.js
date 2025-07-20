const models = require('../models');
const { Op } = require('sequelize');
const path = require('path');
const Koa = require('koa');
const serve = require('koa-static');

const app = new Koa();

// 配置静态文件服务
const staticPath = path.join(__dirname, '../public');
app.use(serve(staticPath));

// 统一的数据处理方法
const dataHandler = (modelName, options = {}) => {
  return async (ctx) => {
    try {
      const { id } = ctx.params;
      const { page = 1, pageSize = 10, keyword, singerId } = ctx.query;
      
      // 构建查询条件
      const where = {};
      let queryOptions = {
        where,
        ...options
      };

      // 添加singerId过滤条件
      if (singerId) {
        where.singer_id = singerId;
      }

      if (keyword) {
        if (modelName === 'Song') {
          // 如果是歌曲查询，同时搜索歌曲名和歌手名
          queryOptions = {
            ...options,
            where: {
              ...where, // 保留已有的where条件（如singerId）
              [Op.or]: [
                { name: { [Op.like]: `%${keyword}%` } },
                { '$singer.name$': { [Op.like]: `%${keyword}%` } }
              ]
            },
            include: [
              {
                model: models.Singer,
                as: 'singer',
                attributes: ['id', 'name']
              }
            ]
          };
        } else if (modelName === 'SongList') {
          // 如果是歌单查询，搜索歌单标题
          queryOptions.where.title = { [Op.like]: `%${keyword}%` };
        } else {
          // 其他表的默认查询
          queryOptions.where.name = { [Op.like]: `%${keyword}%` };
        }
      }
      
      // 如果是按歌手ID查询歌曲
      if (singerId && modelName === 'Song') {
        queryOptions.where.singer_id = singerId;
      }

      // 如果需要分页
      if (ctx.query.page) {
        queryOptions.offset = (page - 1) * pageSize;
        queryOptions.limit = parseInt(pageSize);
      }

      // 单条数据查询
      if (id) {
        const item = await models[modelName].findByPk(id, options);
        if (!item) {
          ctx.body = { code: -1, msg: '数据不存在' };
          return;
        }
        ctx.body = { code: 0, data: item };
        return;
      }

      // 列表查询
      const data = await models[modelName].findAndCountAll(queryOptions);
      ctx.body = { 
        code: 0, 
        data: data.rows,
        total: data.count,
        page: parseInt(page),
        pageSize: parseInt(pageSize)
      };
    } catch (error) {
      console.error(`[${modelName}查询错误]:`, error);
      ctx.body = { code: -1, msg: error.message };
    }
  }
};

// 获取单个歌手详情
const getSingerById = async (ctx) => {
  try {
    const { id } = ctx.params;
    const singer = await models.Singer.findByPk(id);
    
    if (!singer) {
      ctx.body = { code: -1, msg: '歌手不存在' };
      return;
    }
    
    ctx.body = {
      code: 0,
      data: singer
    };
  } catch (error) {
    console.error('[获取歌手详情错误]:', error);
    ctx.body = { code: -1, msg: error.message };
  }
};

// 定义关联查询选项
const includeOptions = {
  Song: {
    include: [
      { model: models.Singer, as: 'singer', attributes: ['id', 'name'] }
    ]
  },
  Comment: {
    include: [
      { model: models.Consumer, as: 'consumer', attributes: ['id', 'username'] }
    ]
  },
  ListSong: {
    include: [
      { model: models.Song, as: 'song' },
      { model: models.SongList, as: 'songList' }
    ]
  }
};

module.exports = {
  getSwipers: dataHandler('Swiper'),
  getSongs: dataHandler('Song', includeOptions.Song),
  getSingers: dataHandler('Singer'),
  getSingerById,
  getSongLists: dataHandler('SongList'),
  getListSongs: dataHandler('ListSong', includeOptions.ListSong),
  getCollects: dataHandler('Collect'),
  getComments: dataHandler('Comment', includeOptions.Comment),
  getRanks: dataHandler('Rank'),
  getConsumers: dataHandler('Consumer'),
  getAdmins: dataHandler('Admin'),
  app
};
