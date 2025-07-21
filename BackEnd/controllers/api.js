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

// 添加收藏
const addCollect = async (ctx) => {
  try {
    const { consumer_id, song_id, song_list_id } = ctx.request.body;
    
    if (!consumer_id || (!song_id && !song_list_id)) {
      ctx.body = { code: -1, msg: '参数不完整' };
      return;
    }
    
    // 检查是否已经收藏
    const existing = await models.Collect.findOne({
      where: {
        consumer_id,
        ...(song_id ? { song_id } : { song_list_id })
      }
    });
    
    if (existing) {
      ctx.body = { code: -1, msg: '已经收藏过了' };
      return;
    }
    
    const collect = await models.Collect.create({
      consumer_id,
      song_id,
      song_list_id
    });
    
    ctx.body = {
      code: 0,
      data: collect,
      msg: '收藏成功'
    };
  } catch (error) {
    console.error('[添加收藏错误]:', error);
    ctx.body = { code: -1, msg: error.message };
  }
};

// 取消收藏
const removeCollect = async (ctx) => {
  try {
    const { consumer_id, song_id, song_list_id } = ctx.request.body;
    
    if (!consumer_id || (!song_id && !song_list_id)) {
      ctx.body = { code: -1, msg: '参数不完整' };
      return;
    }
    
    const result = await models.Collect.destroy({
      where: {
        consumer_id,
        ...(song_id ? { song_id } : { song_list_id })
      }
    });
    
    if (result === 0) {
      ctx.body = { code: -1, msg: '收藏记录不存在' };
      return;
    }
    
    ctx.body = {
      code: 0,
      msg: '取消收藏成功'
    };
  } catch (error) {
    console.error('[取消收藏错误]:', error);
    ctx.body = { code: -1, msg: error.message };
  }
};

// 检查收藏状态
const checkCollect = async (ctx) => {
  try {
    const { consumer_id, song_id, song_list_id } = ctx.query;
    
    if (!consumer_id || (!song_id && !song_list_id)) {
      ctx.body = { code: -1, msg: '参数不完整' };
      return;
    }
    
    const collect = await models.Collect.findOne({
      where: {
        consumer_id,
        ...(song_id ? { song_id } : { song_list_id })
      }
    });
    
    ctx.body = {
      code: 0,
      data: {
        isCollected: !!collect
      }
    };
  } catch (error) {
    console.error('[检查收藏状态错误]:', error);
    ctx.body = { code: -1, msg: error.message };
  }
};

// 用户登录
const login = async (ctx) => {
  try {
    const { username, password } = ctx.request.body;
    
    if (!username || !password) {
      ctx.body = { code: -1, msg: '用户名和密码不能为空' };
      return;
    }
    
    const consumer = await models.Consumer.findOne({
      where: { username }
    });
    
    if (!consumer) {
      ctx.body = { code: -1, msg: '用户不存在' };
      return;
    }
    
    if (consumer.password !== password) {
      ctx.body = { code: -1, msg: '密码错误' };
      return;
    }
    
    // 返回用户信息（不包含密码）
    const userInfo = {
      id: consumer.id,
      username: consumer.username,
      email: consumer.email,
      gender: consumer.gender,
      phone_num: consumer.phone_num,
      birth: consumer.birth,
      introduction: consumer.introduction,
      location: consumer.location,
      avator: consumer.avator
    };
    
    ctx.body = {
      code: 0,
      data: userInfo,
      msg: '登录成功'
    };
  } catch (error) {
    console.error('[登录错误]:', error);
    ctx.body = { code: -1, msg: error.message };
  }
};

// 用户注册
const register = async (ctx) => {
  try {
    const { username, password, email } = ctx.request.body;
    
    if (!username || !password) {
      ctx.body = { code: -1, msg: '用户名和密码不能为空' };
      return;
    }
    
    // 检查用户名是否已存在
    const existingUser = await models.Consumer.findOne({
      where: { username }
    });
    
    if (existingUser) {
      ctx.body = { code: -1, msg: '用户名已存在' };
      return;
    }
    
    // 创建新用户
    const newUser = await models.Consumer.create({
      username,
      password,
      email,
      created_at: new Date(),
      updated_at: new Date()
    });
    
    // 返回用户信息（不包含密码）
    const userInfo = {
      id: newUser.id,
      username: newUser.username,
      email: newUser.email,
      gender: newUser.gender,
      phone_num: newUser.phone_num,
      birth: newUser.birth,
      introduction: newUser.introduction,
      location: newUser.location,
      avator: newUser.avator
    };
    
    ctx.body = {
      code: 0,
      data: userInfo,
      msg: '注册成功'
    };
  } catch (error) {
    console.error('[注册错误]:', error);
    ctx.body = { code: -1, msg: error.message };
  }
};


// 更新用户信息
const updateUser = async (ctx) => {
  try {
    const { id } = ctx.params;
    const { username, email, introduction, avator, gender, phone_num, birth, location } = ctx.request.body;
    
    if (!id) {
      ctx.body = { code: -1, msg: '用户ID不能为空' };
      return;
    }
    
    // 查找用户
    const user = await models.Consumer.findByPk(id);
    if (!user) {
      ctx.body = { code: -1, msg: '用户不存在' };
      return;
    }
    
    // 如果要更新用户名，检查是否已存在
    if (username && username !== user.username) {
      const existingUser = await models.Consumer.findOne({
        where: { 
          username,
          id: { [Op.ne]: id } // 排除当前用户
        }
      });
      
      if (existingUser) {
        ctx.body = { code: -1, msg: '用户名已存在' };
        return;
      }
    }
    
    // 构建更新数据
    const updateData = {
      updated_at: new Date()
    };
    
    if (username !== undefined) updateData.username = username;
    if (email !== undefined) updateData.email = email;
    if (introduction !== undefined) updateData.introduction = introduction;
    if (avator !== undefined) updateData.avator = avator;
    if (gender !== undefined) updateData.gender = gender;
    if (phone_num !== undefined) updateData.phone_num = phone_num;
    if (birth !== undefined) updateData.birth = birth;
    if (location !== undefined) updateData.location = location;
    
    // 更新用户信息
    await user.update(updateData);
    
    // 返回更新后的用户信息（不包含密码）
    const userInfo = {
      id: user.id,
      username: user.username,
      email: user.email,
      gender: user.gender,
      phone_num: user.phone_num,
      birth: user.birth,
      introduction: user.introduction,
      location: user.location,
      avator: user.avator
    };
    
    ctx.body = {
      code: 0,
      data: userInfo,
      msg: '更新成功'
    };
  } catch (error) {
    console.error('[更新用户信息错误]:', error);
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
  addCollect,
  removeCollect,
  checkCollect,
  login,
  register,
  updateUser,
  getComments: dataHandler('Comment', includeOptions.Comment),
  getRanks: dataHandler('Rank'),
  getConsumers: dataHandler('Consumer'),
  getAdmins: dataHandler('Admin'),
  app
};
