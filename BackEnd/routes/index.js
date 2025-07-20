const router = require('koa-router')();
const api = require('../controllers/api');

// 添加 API 前缀
router.prefix('/api');

router.get('/swipers', api.getSwipers);
router.get('/songs', api.getSongs);
router.get('/singers', api.getSingers);
router.get('/singers/:id', api.getSingerById);
router.get('/songlists', api.getSongLists);
router.get('/listsongs', api.getListSongs);
router.get('/collects', api.getCollects);
router.get('/comments', api.getComments);
router.get('/ranks', api.getRanks);
router.get('/consumers', api.getConsumers);
router.get('/admins', api.getAdmins);

module.exports = router;
