
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;
CREATE DATABASE IF NOT EXISTS music_app DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE music_app;
-- ----------------------------
-- Table structure for admins
-- ----------------------------
DROP TABLE IF EXISTS `admins`;
CREATE TABLE `admins`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `password` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `created_at` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `username`(`username` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of admins
-- ----------------------------
INSERT INTO `admins` VALUES (1, 'admin', '123456', NULL);
INSERT INTO `admins` VALUES (2, 'admin2', '123456', NULL);

-- ----------------------------
-- Table structure for collects
-- ----------------------------
DROP TABLE IF EXISTS `collects`;
CREATE TABLE `collects`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `consumer_id` int NOT NULL,
  `song_id` int NULL DEFAULT NULL,
  `song_list_id` int NULL DEFAULT NULL,
  `created_at` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `consumer_id`(`consumer_id` ASC) USING BTREE,
  INDEX `song_id`(`song_id` ASC) USING BTREE,
  INDEX `song_list_id`(`song_list_id` ASC) USING BTREE,
  CONSTRAINT `collects_ibfk_1` FOREIGN KEY (`consumer_id`) REFERENCES `consumers` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `collects_ibfk_2` FOREIGN KEY (`song_id`) REFERENCES `songs` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `collects_ibfk_3` FOREIGN KEY (`song_list_id`) REFERENCES `song_lists` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of collects
-- ----------------------------
INSERT INTO `collects` VALUES (2, 2, NULL, 1, NULL);
INSERT INTO `collects` VALUES (3, 3, 2, NULL, NULL);

-- ----------------------------
-- Table structure for comments
-- ----------------------------
DROP TABLE IF EXISTS `comments`;
CREATE TABLE `comments`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `consumer_id` int NOT NULL,
  `song_id` int NULL DEFAULT NULL,
  `song_list_id` int NULL DEFAULT NULL,
  `content` text CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `created_at` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `consumer_id`(`consumer_id` ASC) USING BTREE,
  INDEX `song_id`(`song_id` ASC) USING BTREE,
  INDEX `song_list_id`(`song_list_id` ASC) USING BTREE,
  CONSTRAINT `comments_ibfk_1` FOREIGN KEY (`consumer_id`) REFERENCES `consumers` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `comments_ibfk_2` FOREIGN KEY (`song_id`) REFERENCES `songs` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `comments_ibfk_3` FOREIGN KEY (`song_list_id`) REFERENCES `song_lists` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of comments
-- ----------------------------
INSERT INTO `comments` VALUES (1, 1, 1, NULL, '满满的回忆！', NULL);
INSERT INTO `comments` VALUES (2, 2, NULL, 1, '周杰伦的歌都很好听！', NULL);
INSERT INTO `comments` VALUES (3, 3, 2, NULL, 'Classic love song!', NULL);

-- ----------------------------
-- Table structure for consumers
-- ----------------------------
DROP TABLE IF EXISTS `consumers`;
CREATE TABLE `consumers`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `password` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `email` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `avatar` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `created_at` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `username`(`username` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of consumers
-- ----------------------------
INSERT INTO `consumers` VALUES (1, 'user1', '123456', 'user1@example.com', '/images/avatars/1.jpg', NULL);
INSERT INTO `consumers` VALUES (2, 'user2', '123456', 'user2@example.com', '/images/avatars/2.jpg', NULL);
INSERT INTO `consumers` VALUES (3, 'user3', '123456', 'user3@example.com', '/images/avatars/3.jpg', NULL);

-- ----------------------------
-- Table structure for list_songs
-- ----------------------------
DROP TABLE IF EXISTS `list_songs`;
CREATE TABLE `list_songs`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `song_list_id` int NOT NULL,
  `song_id` int NOT NULL,
  `created_at` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `song_list_id`(`song_list_id` ASC) USING BTREE,
  INDEX `song_id`(`song_id` ASC) USING BTREE,
  CONSTRAINT `list_songs_ibfk_1` FOREIGN KEY (`song_list_id`) REFERENCES `song_lists` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `list_songs_ibfk_2` FOREIGN KEY (`song_id`) REFERENCES `songs` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of list_songs
-- ----------------------------
INSERT INTO `list_songs` VALUES (1, 1, 1, NULL);
INSERT INTO `list_songs` VALUES (2, 2, 2, NULL);
INSERT INTO `list_songs` VALUES (3, 3, 3, NULL);

-- ----------------------------
-- Table structure for ranks
-- ----------------------------
DROP TABLE IF EXISTS `ranks`;
CREATE TABLE `ranks`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `consumer_id` int NOT NULL,
  `song_list_id` int NOT NULL,
  `score` int NOT NULL,
  `created_at` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `consumer_id`(`consumer_id` ASC) USING BTREE,
  INDEX `song_list_id`(`song_list_id` ASC) USING BTREE,
  CONSTRAINT `ranks_ibfk_1` FOREIGN KEY (`consumer_id`) REFERENCES `consumers` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `ranks_ibfk_2` FOREIGN KEY (`song_list_id`) REFERENCES `song_lists` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ranks
-- ----------------------------
INSERT INTO `ranks` VALUES (1, 1, 1, 9, NULL);
INSERT INTO `ranks` VALUES (2, 2, 2, 8, NULL);
INSERT INTO `ranks` VALUES (3, 3, 3, 9, NULL);

-- ----------------------------
-- Table structure for singers
-- ----------------------------
DROP TABLE IF EXISTS `singers`;
CREATE TABLE `singers`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `gender` enum('男','女','组合','未知') CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '未知',
  `pic` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `description` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
  `created_at` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of singers
-- ----------------------------
INSERT INTO `singers` VALUES (1, '周杰伦', '男', '/images/singers/jay.jpg', '华语流行乐天王', NULL);
INSERT INTO `singers` VALUES (2, 'Taylor Swift', '女', '/images/singers/taylor.jpg', '美国流行音乐歌手', NULL);
INSERT INTO `singers` VALUES (3, 'BLACKPINK', '组合', '/images/singers/blackpink.jpg', '韩国女子组合', NULL);

-- ----------------------------
-- Table structure for song_lists
-- ----------------------------
DROP TABLE IF EXISTS `song_lists`;
CREATE TABLE `song_lists`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `style` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `pic` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `introduction` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
  `created_at` datetime NULL DEFAULT NULL,
  `user_id` int NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of song_lists
-- ----------------------------
INSERT INTO `song_lists` VALUES (1, '周杰伦精选', '华语', '/images/playlists/jay.jpg', '周杰伦热门歌曲精选', NULL, NULL);
INSERT INTO `song_lists` VALUES (2, '欧美流行', '欧美', '/images/playlists/pop.jpg', '欧美经典流行音乐合集', NULL, NULL);
INSERT INTO `song_lists` VALUES (3, 'K-POP精选', '韩语', '/images/playlists/kpop.jpg', '最热韩语歌曲合集', NULL, NULL);
INSERT INTO `song_lists` VALUES (4, 'tiantian', NULL, NULL, '22wo', '2025-07-21 02:28:45', 1);
INSERT INTO `song_lists` VALUES (5, 'yangyuhang', NULL, NULL, 'sb', '2025-07-21 06:21:39', 1);
INSERT INTO `song_lists` VALUES (6, '909', NULL, NULL, '', '2025-07-21 07:34:12', -1);
INSERT INTO `song_lists` VALUES (7, 'where', NULL, NULL, '', '2025-07-21 07:43:04', 1);
INSERT INTO `song_lists` VALUES (8, 'YYH', NULL, NULL, 'SB', '2025-07-21 07:57:14', 2);
INSERT INTO `song_lists` VALUES (9, '666', NULL, NULL, '', '2025-07-21 07:57:23', 2);
INSERT INTO `song_lists` VALUES (10, '11', NULL, NULL, '', '2025-07-21 07:58:35', 2);
INSERT INTO `song_lists` VALUES (11, '?', NULL, NULL, '', '2025-07-21 07:58:52', 2);

-- ----------------------------
-- Table structure for songs
-- ----------------------------
DROP TABLE IF EXISTS `songs`;
CREATE TABLE `songs`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `singer_id` int NULL DEFAULT NULL,
  `url` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `pic` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `lyric` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
  `created_at` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `singer_id`(`singer_id` ASC) USING BTREE,
  CONSTRAINT `songs_ibfk_1` FOREIGN KEY (`singer_id`) REFERENCES `singers` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of songs
-- ----------------------------
INSERT INTO `songs` VALUES (1, '稻香', 1, '/music/daoxiang.mp3', '/images/songs/daoxiang.jpg', '对这个世界如果你有太多的抱怨...', NULL);
INSERT INTO `songs` VALUES (2, 'Love Story', 2, '/music/lovestory.mp3', '/images/songs/lovestory.jpg', 'We were both young when I first saw you...', NULL);
INSERT INTO `songs` VALUES (3, 'How You Like That', 3, '/music/howulikethat.mp3', '/images/songs/hylt.jpg', 'BLACKPINK in your area...', NULL);

-- ----------------------------
-- Table structure for swipers
-- ----------------------------
DROP TABLE IF EXISTS `swipers`;
CREATE TABLE `swipers`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `pic` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `url` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `title` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `created_at` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of swipers
-- ----------------------------
INSERT INTO `swipers` VALUES (1, '/images/banners/jay.jpg', '/playlist/1', '周杰伦新专辑', NULL);
INSERT INTO `swipers` VALUES (2, '/images/banners/taylor.jpg', '/playlist/2', 'Taylor Swift演唱会', NULL);
INSERT INTO `swipers` VALUES (3, '/images/banners/blackpink.jpg', '/playlist/3', 'BLACKPINK回归', NULL);

SET FOREIGN_KEY_CHECKS = 1;
