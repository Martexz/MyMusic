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
router.post('/collects', api.addCollect);
router.delete('/collects', api.removeCollect);
router.get('/collects/check', api.checkCollect);
router.post('/login', api.login);
router.post('/register', api.register);
router.put('/users/:id', api.updateUser);
router.get('/user/id', api.getUserIdByUsername);
router.get('/comments', api.getComments);
router.get('/ranks', api.getRanks);
router.get('/consumers', api.getConsumers);
router.get('/admins', api.getAdmins);
router.post('/songLists/create', api.createSongList);
router.get('/songLists/created', api.getCreatedSongLists);

module.exports = router;
