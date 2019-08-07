CREATE DATABASE master;
CREATE TABLE master.users (
  id INT NOT NULL AUTO_INCREMENT,
  email VARCHAR(255),
  first_name VARCHAR(255),
  last_name VARCHAR(255),
  PRIMARY KEY(id)
);

CREATE DATABASE user_stuff;
CREATE TABLE user_stuff.photos (
  id INT NOT NULL AUTO_INCREMENT,
  user_id INT NOT NULL,
  link VARCHAR(4096),
  PRIMARY KEY(id)
);

CREATE TABLE user_stuff.websites (
  id INT NOT NULL AUTO_INCREMENT,
  user_id INT NOT NULL,
  link VARCHAR(4096),
  PRIMARY KEY(id)
);

CREATE DATABASE user_properties;
CREATE TABLE user_properties.avatars (
  id INT NOT NULL AUTO_INCREMENT,
  user_id INT NOT NULL,
  link VARCHAR(4096),
  PRIMARY KEY(id)
);

INSERT INTO master.users ( email, first_name, last_name) VALUES ("gaorlov@gmail.com", "Greg", "Orlov");


SELECT
  id
INTO
  @user_id
FROM
  master.users
WHERE
  email = "gaolrov@gmail.com";

INSERT INTO user_properties.avatars (user_id, link) VALUES (@user_id, "http://placekitten.com/320/320");
INSERT INTO user_stuff.photos (user_id, link) VALUES (@user_id, "http://placekitten.com/480/320");
INSERT INTO user_stuff.websites (user_id, link) VALUES (@user_id, "http://placekitten.com");