CREATE DATABASE master;
CREATE TABLE master.users (
  id INT NOT NULL AUTO_INCREMENT,
  email VARCHAR(255),
  first_name VARCHAR(255),
  last_name VARCHAR(255),
  PRIMARY KEY(id)
);

CREATE TABLE master.websites (
  id INT NOT NULL AUTO_INCREMENT,
  link VARCHAR(4096),
  PRIMARY KEY(id)
);

# --- user stuff database ---

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

# --- user properties database ---

CREATE DATABASE user_properties;
CREATE TABLE user_properties.avatars (
  id INT NOT NULL AUTO_INCREMENT,
  user_id INT NOT NULL,
  link VARCHAR(4096),
  PRIMARY KEY(id)
);

CREATE TABLE user_properties.hypersensitive_data (
  id INT NOT NULL AUTO_INCREMENT,
  user_id INT NOT NULL,
  secrets VARCHAR(4096),
  PRIMARY KEY(id)
);

# --- dashed name database ---

CREATE DATABASE `user_name-test`;
CREATE TABLE `user_name-test`.`images` (
  id INT NOT NULL AUTO_INCREMENT,
  user_id INT NOT NULL,
  link VARCHAR(4096),
  PRIMARY KEY(id)
);

# --- seeds ---

INSERT INTO master.users ( email, first_name, last_name) VALUES ("gaorlov@gmail.com", "Greg", "Orlov");

INSERT INTO user_properties.avatars ( user_id, link ) VALUES ( 1, "http://placekitten.com/320/320" );
INSERT INTO user_properties.hypersensitive_data ( user_id, secrets ) VALUES ( 1, "What I did last summer." );
INSERT INTO user_stuff.photos ( user_id, link ) VALUES ( 1, "http://placekitten.com/480/320" );
INSERT INTO user_stuff.websites ( user_id, link ) VALUES ( 1, "http://placekitten.com" );
INSERT INTO `user_name-test`.`avatars` ( user_id, link ) VALUES ( 1, "http://placekitten.com/320/320" );