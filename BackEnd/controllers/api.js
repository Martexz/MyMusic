const models = require('../models');
const { Op } = require('sequelize');
const path = require('path');
const Koa = require('koa');
const serve = require('koa-static');
const multer = require('@koa/multer');
const fs = require('fs');

const app = new Koa();

// 配置静态文件服务
const staticPath = path.join(__dirname, '../public');
app.use(serve(staticPath));

// 确保上传目录存在
const uploadDir = path.join(__dirname, '../public/uploads/avatars');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// 配置multer用于头像上传
const avatarUpload = multer({
  storage: multer.diskStorage({
    destination: (req, file, cb) => {
      cb(null, uploadDir);
    },
    filename: (req, file, cb) => {
      const ext = path.extname(file.originalname);
      const filename = `avatar_${Date.now()}${ext}`;
      cb(null, filename);
    }
  }),
  limits: {
    fileSize: 5 * 1024 * 1024 // 5MB限制
  },
  fileFilter: (req, file, cb) => {
    // 检查文件类型
    console.log('收到文件上传:', {
      fieldname: file.fieldname,
      originalname: file.originalname,
      mimetype: file.mimetype,
      size: file.size
    });
    
    if (file.mimetype.startsWith('image/')) {
      console.log('文件类型验证通过:', file.mimetype);
      cb(null, true);
    } else {
      console.log('文件类型验证失败:', file.mimetype);
      cb(new Error('只允许上传图片文件'));
    }
  }
});

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
      avator: consumer.avatar  // 数据库字段是avatar，但前端期望avator
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
      avator: newUser.avatar  // 数据库字段是avatar，但前端期望avator
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
    if (avator !== undefined) updateData.avatar = avator;  // 修正字段名：avator -> avatar
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
      avator: user.avatar  // 数据库字段是avatar，但前端期望avator
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



// 新增歌单
const createSongList = async (ctx) => {
  try {
    const { title, introduction = '', user_id } = ctx.request.body;

    if (!title || !user_id) {
      ctx.body = { code: -1, msg: '缺少必要参数 title 或 user_id' };
      return;
    }

    // 手动设置 id = 当前数量 + 1
    const count = await models.SongList.count();

    const newSongList = await models.SongList.create({
      id: count + 1,
      title,
      introduction,
      user_id
    });

    ctx.body = {
      code: 0,
      msg: '创建成功',
      data: newSongList
    };
  } catch (error) {
    console.error('[创建歌单错误]:', error);
    ctx.body = { code: -1, msg: '创建失败: ' + error.message };
  }
};

// 获取当前用户创建的歌单
const getCreatedSongLists = async (ctx) => {
  try {
    const userId = Number(ctx.query.userId);
    if (!userId) {
      ctx.body = { code: -1, msg: '缺少或无效的 userId 参数' };
      return;
    }

    const lists = await models.SongList.findAll({
      where: { user_id: userId },
      order: [['created_at', 'DESC']]
    });

    ctx.body = {
      code: 0,
      data: lists
    };
  } catch (error) {
    console.error('[getCreatedSongLists 错误]', error);
    ctx.body = { code: -1, msg: error.message };
  }
};


// 根据用户名获取用户ID
const getUserIdByUsername = async (ctx) => {
  try {
    const { username } = ctx.query;

    if (!username) {
      ctx.body = { code: -1, msg: '缺少 username 参数' };
      return;
    }

    const user = await models.Consumer.findOne({
      where: { username },
      attributes: ['id', 'username']  // 只返回id和username
    });

    if (!user) {
      ctx.body = { code: -1, msg: '用户不存在' };
      return;
    }

    ctx.body = {
      code: 0,
      data: {
        user_id: user.id,
        username: user.username
      }
    };
  } catch (error) {
    console.error('[getUserIdByUsername 错误]:', error);
    ctx.body = { code: -1, msg: error.message };
  }
};

// 添加歌曲到歌单
const addSongToPlaylist = async (ctx) => {
  try {
    const { songListId, songId } = ctx.request.body;
    
    if (!songListId || !songId) {
      ctx.body = { code: -1, msg: '歌单ID和歌曲ID不能为空' };
      return;
    }

    // 检查歌曲是否已在歌单中
    const existing = await models.ListSong.findOne({
      where: {
        song_list_id: songListId,
        song_id: songId
      }
    });

    if (existing) {
      ctx.body = { code: -1, msg: '歌曲已在歌单中' };
      return;
    }

    // 添加歌曲到歌单
    const listSong = await models.ListSong.create({
      song_list_id: songListId,
      song_id: songId
    });

    ctx.body = { code: 0, data: listSong, msg: '添加成功' };
  } catch (error) {
    console.error('[添加歌曲到歌单错误]:', error);
    ctx.body = { code: -1, msg: error.message };
  }
};

// 从歌单中移除歌曲
const removeSongFromPlaylist = async (ctx) => {
  try {
    const { songListId, songId } = ctx.request.body;
    
    if (!songListId || !songId) {
      ctx.body = { code: -1, msg: '歌单ID和歌曲ID不能为空' };
      return;
    }

    // 删除歌单中的歌曲
    const result = await models.ListSong.destroy({
      where: {
        song_list_id: songListId,
        song_id: songId
      }
    });

    if (result > 0) {
      ctx.body = { code: 0, msg: '移除成功' };
    } else {
      ctx.body = { code: -1, msg: '歌曲不在歌单中' };
    }
  } catch (error) {
    console.error('[从歌单移除歌曲错误]:', error);
    ctx.body = { code: -1, msg: error.message };
  }
};

// 获取歌单中的歌曲
const getPlaylistSongs = async (ctx) => {
  try {
    const { playlistId } = ctx.params;
    
    if (!playlistId) {
      ctx.body = { code: -1, msg: '歌单ID不能为空' };
      return;
    }

    // 获取歌单中的歌曲，包含歌曲详细信息和歌手信息
    const listSongs = await models.ListSong.findAll({
      where: {
        song_list_id: playlistId
      },
      include: [
        {
          model: models.Song,
          as: 'song',
          include: [
            {
              model: models.Singer,
              as: 'singer',
              attributes: ['id', 'name', 'pic']
            }
          ]
        }
      ],
      order: [['id', 'ASC']] // 按添加顺序排序
    });

    // 提取歌曲数据
    const songs = listSongs.map(item => item.song);
    
    ctx.body = { 
      code: 0, 
      data: songs, 
      total: songs.length,
      msg: '获取成功' 
    };
  } catch (error) {
    console.error('[获取歌单歌曲错误]:', error);
    ctx.body = { code: -1, msg: error.message };
  }
};

// 上传用户头像
const uploadAvatar = async (ctx) => {
  return new Promise((resolve, reject) => {
    avatarUpload.single('avatar')(ctx, async () => {
      try {
        console.log('开始处理头像上传...');
        console.log('请求体:', ctx.request.body);
        
        const { userId } = ctx.request.body;
        const file = ctx.request.file;

        console.log('用户ID:', userId);
        console.log('上传文件信息:', file ? {
          fieldname: file.fieldname,
          originalname: file.originalname,
          filename: file.filename,
          mimetype: file.mimetype,
          size: file.size
        } : '无文件');

        if (!file) {
          console.log('错误: 没有上传文件');
          ctx.body = { code: -1, message: '没有上传文件' };
          resolve();
          return;
        }

        if (!userId) {
          console.log('错误: 用户ID不能为空');
          ctx.body = { code: -1, message: '用户ID不能为空' };
          resolve();
          return;
        }

        // 构建文件URL路径
        const avatarPath = `/uploads/avatars/${file.filename}`;
        console.log('头像路径:', avatarPath);

        // 确保userId是数字类型
        const userIdNumber = parseInt(userId);
        console.log('用户ID (原始):', userId, '(转换后):', userIdNumber);

        // 先检查用户是否存在
        const existingUser = await models.Consumer.findByPk(userIdNumber);
        console.log('用户存在检查:', existingUser ? '用户存在' : '用户不存在');

        if (!existingUser) {
          console.log('错误: 用户不存在');
          ctx.body = { 
            code: -1, 
            message: '用户不存在' 
          };
          resolve();
          return;
        }

        // 更新用户头像信息到数据库
        const [updateCount] = await models.Consumer.update(
          { avatar: avatarPath },  // 修正字段名：avator -> avatar
          { where: { id: userIdNumber } }
        );

        console.log('数据库更新结果:', updateCount);

        if (updateCount > 0) {
          const responseData = { 
            code: 0, 
            data: avatarPath, 
            message: '头像上传成功' 
          };
          console.log('成功响应:', responseData);
          ctx.body = responseData;
        } else {
          const errorData = { 
            code: -1, 
            message: '更新用户头像失败' 
          };
          console.log('失败响应:', errorData);
          ctx.body = errorData;
        }
        resolve();
      } catch (error) {
        console.error('[上传头像错误]:', error);
        const errorResponse = { code: -1, message: error.message };
        console.log('异常响应:', errorResponse);
        ctx.body = errorResponse;
        resolve();
      }
    });
  });
};


module.exports = {
  getSwipers: dataHandler('Swiper'),
  getSongs: dataHandler('Song', includeOptions.Song),
  getSingers: dataHandler('Singer'),
  getSingerById,
  getSongLists: dataHandler('SongList', {
    where: {
      user_id: null 
    }
  }),  
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
  createSongList,
  getCreatedSongLists,
  getUserIdByUsername,
  addSongToPlaylist,
  removeSongFromPlaylist,
  getPlaylistSongs,
  uploadAvatar,
  app,
};
