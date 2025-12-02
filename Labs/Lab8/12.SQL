DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS videos CASCADE;
DROP TABLE IF EXISTS watch_history CASCADE;
CREATE TABLE users (
                       user_id INT PRIMARY KEY,
                       username VARCHAR(50),
                       email VARCHAR(100),
                       subscription_type VARCHAR(20),
                       country VARCHAR(50)
);
CREATE TABLE videos (
                        video_id INT PRIMARY KEY,
                        title VARCHAR(200),
                        genre VARCHAR(50),
                        release_year INT,
                        duration_minutes INT,
                        rating DECIMAL(3,1)
);
CREATE TABLE watch_history (
                               watch_id INT PRIMARY KEY,
                               user_id INT,
                               video_id INT,
                               watch_date TIMESTAMP,
                               watch_duration_minutes INT,
                               completed BOOLEAN,
                               FOREIGN KEY (user_id) REFERENCES users(user_id),
                               FOREIGN KEY (video_id) REFERENCES videos(video_id)
);
SELECT v.title, w.watch_date, w.completed
FROM watch_history w
         JOIN videos v ON w.video_id = v.video_id
WHERE w.user_id = 12345
ORDER BY w.watch_date DESC;
CREATE INDEX idx_watch_history_user_date
    ON watch_history (user_id, watch_date DESC);
--task 2
CREATE INDEX idx_videos_title_search
    ON videos (lower(trim(title)));
SELECT video_id, title, genre, release_year
FROM videos
WHERE lower(trim(title)) LIKE 'matrix%';

--task3
CREATE INDEX wh_user_idx      ON watch_history(user_id);
DROP INDEX wh_user_idx;

--task4
CREATE INDEX idx_watch_history_completed
    ON watch_story (video_id)
    WHERE completed=TRUE;