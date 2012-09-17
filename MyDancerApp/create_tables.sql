DROP TABLE IF EXISTS kwasr.Event;
CREATE TABLE kwasr.Event (
	eve_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	eve_name_en VARCHAR(255) NOT NULL UNIQUE,
	eve_countrycode CHAR(2) NOT NULL,
	eve_photo_url VARCHAR(255),
	eve_start_date DATE NOT NULL,
	eve_end_date DATE NOT NULL
)
COMMENT "Table with global events, like Roskilde";

INSERT INTO kwasr.Event VALUES 
	(NULL, "IFFR", "NL", "http://upload.wikimedia.org/wikipedia/commons/1/16/Iffr-logo_medium-1.jpg", "2012-10-10", "2012-10-20"),
	(NULL, "Roskilde", "DK", "http://www.yorkvision.co.uk/wp-content/uploads/2012/06/Roskilde-Festival.jpg", "2013-01-20", "2013-02-02");

DROP TABLE IF EXISTS kwasr.EventTrans;
CREATE TABLE kwasr.EventTrans (
	eve_id INT NOT NULL,
	evet_languagecode CHAR(2) NOT NULL,
	evet_name VARCHAR(255) NOT NULL,
	evet_name_slug VARCHAR(255) NOT NULL,
	evet_description VARCHAR(65000) NOT NULL,
	evet_official_website_url VARCHAR(255),
	evet_map_url VARCHAR(255),
	UNIQUE KEY (eve_id, evet_languagecode),
	UNIQUE (evet_name_slug, evet_languagecode)
)
COMMENT "one event translation per row";

INSERT INTO kwasr.EventTrans VALUES (
	1, 
	"en", 
	"International film festival Rotterdam",
	"international_film_festival_rotterdam",
	"Great film festival in Rotterdam", 
	"http://www.filmfestivalrotterdam.com/en/",
	"http://www.filmfestivalrotterdam.com/Assets/Uploads/Images/Festival/festivallocaties2012.png"
),(
	1, 
	"nl", 
	"Internationaal film festival Rotterdam", 
	"internationaal_film_festival_rotterdam", 
	"Leuk filmfestival in Rotterdam", 
	"http://www.filmfestivalrotterdam.com/nl/",
	"http://www.filmfestivalrotterdam.com/Assets/Uploads/Images/Festival/festivallocaties2012.png"
),(
	2,
	"en", 
	"Roskilde festival", 
	"roskilde_festival", 
	"Big pop festival in roskilde", 
	"http://roskilde-festival.dk/uk/",
	"http://www.universitetsradioen.dk/roskilde/1998/kort.jpg"
),(
	2,
	"nl", 
	"Roskilde festival", 
	"roskilde_festival", 
	"Groot pop festival in roskilde", 
	"http://roskilde-festival.dk/uk/",
	"http://www.universitetsradioen.dk/roskilde/1998/kort.jpg"
);

DROP TABLE IF EXISTS kwasr.Location;
CREATE TABLE kwasr.Location (
	loc_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	loc_name_en VARCHAR(255) NOT NULL,
	eve_id INT NOT NULL,
	loc_photo_url VARCHAR(255),
	loc_latitude REAL NOT NULL,
	loc_longitude REAL NOT NULL,
	loc_radius_meters INT NOT NULL,
	UNIQUE (eve_id, loc_name_en)
)
COMMENT "A location where Showings happen, like orange stage";

INSERT INTO kwasr.Location VALUES 
	( NULL, "Pathe zaal 1", 1, "", 51.921165,  4.473467, 10 ),
	( NULL, "Pathe zaal 2", 1, "", 51.921354,  4.473243, 10 ),
	( NULL, "Orange stage", 2, "", 55.621236, 12.077235, 100 ),
	( NULL, "Arena",        2, "", 55.6197,   12.083887, 30 );

DROP TABLE IF EXISTS kwasr.LocationTrans;
CREATE TABLE kwasr.LocationTrans (
	loc_id INT NOT NULL,
	loct_languagecode CHAR(2) NOT NULL,
	loct_name VARCHAR(255) NOT NULL,
	loct_name_slug VARCHAR(255) NOT NULL,
	loct_description VARCHAR(65000) NOT NULL,
	UNIQUE KEY (loc_id, loct_languagecode)
)
COMMENT "one location translation per row";

INSERT INTO kwasr.LocationTrans VALUES 
	( 1, "NL", "Pathe zaal 1", "pathe_1", "De grootste zaal van deze pathe" ),
	( 1, "EN", "Pathe screen 1", "pathe_1", "The biggest screen of this cinema" ),
	( 2, "NL", "Pathe zaal 2", "pathe_2", "Gezellig en knus zaaltje" ),
	( 2, "EN", "Pathe screen 2", "pathe_2", "Nice and cozy room" ),
	( 3, "NL", "Oranje podium", "oranje", "Vroeger van Mick Jagger geweest" ),
	( 3, "EN", "Orange stage", "orange", "This orange monster was originally used for a Rolling stones tour" ),
	( 4, "NL", "Arena", "arena", "Overdekt. Heette vroeger 'groen'" ),
	( 4, "EN", "Arena", "arena", "Biggest tent in Roskilde" );

DROP TABLE IF EXISTS kwasr.Feature;
CREATE TABLE kwasr.Feature (
	fea_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	fea_name_en VARCHAR(255) NOT NULL,
	fea_imdb_id INT,
	fea_lastfm_id VARCHAR(255),
	fea_photo_url VARCHAR(255)
)
COMMENT "the band or movie that is playing";

INSERT INTO kwasr.Feature VALUES
	( 1, "Pulp Fiction", 110912, NULL, "http://ia.media-imdb.com/images/M/MV5BMjE0ODk2NjczOV5BMl5BanBnXkFtZTYwNDQ0NDg4._V1._SY317_CR4,0,214,317_.jpg" ),
	( 2, "The Expendables 2", 1764651, NULL, "http://ia.media-imdb.com/images/M/MV5BMTQzODkwNDQxNV5BMl5BanBnXkFtZTcwNTQ1ODAxOA@@._V1._SY317_.jpg"),
	( 3, "The Hunger games", 1392170, NULL, "http://ia.media-imdb.com/images/M/MV5BMjA4NDg3NzYxMF5BMl5BanBnXkFtZTcwNTgyNzkyNw@@._V1._SY317_.jpg"),
	( 4, "The Smashing Pumpkins", NULL, "The+Smashing+Pumpkins", "http://userserve-ak.last.fm/serve/500/216737/The+Smashing+Pumpkins+sdsd.jpg"),
	( 5, "Fatboy Slim", NULL, "Fatboy+Slim", "http://userserve-ak.last.fm/serve/_/10575075/Fatboy+Slim+Fatboy_051103123114921_wideweb.jpg"),
	( 6, "De Raggende Manne", NULL, "De+Raggende+Manne", "http://userserve-ak.last.fm/serve/_/174346/De+Raggende+Manne.jpg")


DROP TABLE IF EXISTS kwasr.FeatureTrans;
CREATE TABLE kwasr.FeatureTrans (
	fea_id INT NOT NULL,
	feat_languagecode CHAR(2) NOT NULL,
	feat_name VARCHAR(255) NOT NULL,
	feat_name_slug VARCHAR(255) NOT NULL,
	feat_description VARCHAR(65000) NOT NULL,
	UNIQUE KEY (fea_id, feat_languagecode)
)
COMMENT "one Feature translation per row";

INSERT INTO kwasr.FeatureTrans VALUES
	(1, "en", "Pulp Fiction", "pulp-fiction", "The lives of two mob hit men, a boxer, a gangster's wife, and a pair of diner bandits intertwine in four tales of violence and redemption."),
	(1, "nl", "Pulp Fiction", "pulp-fiction", "Pulp Fiction is een Amerikaanse misdaadfilm uit 1994 onder regie van Quentin Tarantino."),
	(2, "en", "The expendables 2", "expandables2", "The Expendables 2 is a 2012 American ensemble action film directed by Simon West and written by Richard Wenk and Sylvester Stallone."),
	(2, "nl", "The expendables 2", "expandables2", "The Expendables 2 is een actiefilm geregisseerd door Simon West."),
	(3, "en", "The Hunger games", "hunger-games", "The Hunger Games is a 2012 American science fiction film directed by Gary Ross and based on the novel of the same name by Suzanne Collins."),
	(3, "nl", "The Hunger games", "hunger-games", "The Hunger Games is een Amerikaanse sciencefiction film uit 2012, gebaseerd op het gelijknamige boek van Suzanne Collins."),
	(4, "en", "The Smashing Pumpkins", "smashing-pumpkins", "The Smashing Pumpkins are an American alternative rock band from Chicago, Illinois, formed in 1988."),
	(4, "nl", "The Smashing Pumpkins", "smashing-pumpkins", "The Smashing Pumpkins is een Amerikaanse alternatieverockgroep die zijn eerste single uitbracht in 1990."),
	(5, "en", "Fatboy Slim", "fatboy-slim", "Norman Quentin Cook, also known by his stage name Fatboy Slim, is an English DJ, electronic dance music musician, and record producer."),
	(5, "nl", "Fatboy Slim", "fatboy-slim", "Norman Cook (Bromley, 13 juli 1963), ook bekend als Fatboy Slim, is een Brits muzikant."),
	(6, "en", "De Raggende Manne", "de-raggende-manne", "Weird Dutch band"),
	(6, "nl", "De Raggende Manne", "de-raggende-manne", "De Raggende Manne was een Nederlandse band, die in 1988 vrij spontaan ontstond naar aanleiding van een jamsessie.");

DROP TABLE IF EXISTS kwasr.User;
CREATE TABLE kwasr.User (
	use_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	use_name VARCHAR(255) NOT NULL,
	UNIQUE (use_name)
)
COMMENT "the user of kwasr.net";

INSERT INTO kwasr.User VALUES 
	(1, 'jasper'),
	(2, 'bob'),
	(3, 'allard');

DROP TABLE IF EXISTS kwasr.Showing;
CREATE TABLE kwasr.Showing (
	sho_id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	loc_id INT UNSIGNED NOT NULL,
	fea_id INT UNSIGNED NOT NULL,
	sho_start_datetime TIMESTAMP NOT NULL,
	sho_end_datetime TIMESTAMP NOT NULL,
	sho_nr_posts INT UNSIGNED NOT NULL DEFAULT 0,
	sho_avg_post_rating DECIMAL(3,2) UNSIGNED NOT NULL DEFAULT 0
)
COMMENT "a single Showing by a band (or movie or ) in a location";

INSERT INTO kwasr.Showing VALUES 
	(null, 1, 3, "2012-09-14 17:00", "2012-09-14 19:00", NULL, NULL ),
	(null, 1, 1, "2012-09-14 20:00", "2012-09-14 22:00", NULL, NULL ),
	(null, 2, 2, "2012-09-15 17:30", "2012-09-15 20:00", NULL, NULL ),
	(null, 2, 1, "2012-09-14 20:30", "2012-09-14 22:30", NULL, NULL ),
	(null, 3, 4, "2012-06-20 20:30", "2012-06-20 22:30", NULL, NULL ),
	(null, 3, 5, "2012-06-21 20:30", "2012-06-21 22:30", NULL, NULL ),
	(null, 4, 6, "2012-06-22 20:30", "2012-06-22 22:30", NULL, NULL );
	

DROP TABLE IF EXISTS Post;
CREATE TABLE Post (
	sho_id INT NOT NULL,	
	use_id INT NOT NULL,
	pos_rating TINYINT NOT NULL,
	pos_message VARCHAR(255) NOT NULL,
	pos_datetime TIMESTAMP NOT NULL,
	UNIQUE KEY (sho_id, use_id)
)
COMMENT "a post by a user";

INSERT INTO Post VALUES
	(2, 1, 5, "Beste film ooit gemaakt", "2012-09-14 22:00"),
	(2, 2, 4, "Geinig, maar niet episch", "2012-09-14 22:08"),
	(2, 3, 1, "Ik snapte m niet. Eerst wordt iemand vermoord, daarna is ie er weer.", "2012-09-14 22:12"),
	(3, 2, 4, "Klasse. Wat een acteerwerk", "2012-09-15 20:10"),
	(3, 3, 2, "Daar zijn ze nu echt wel te oud voor", "2012-09-15 20:20"),
	(5, 1, 2, "Wat kunnen die een herrie maken. Geef mij maar de raggende manne", "2012-06-20 22:30"),
	(6, 1, 4, "De hele avond gedanst!", "2012-06-21 22:30"),
	(6, 2, 4, "Die lui hebben echt lol samen", "2012-06-21 22:30"),
	(6, 3, 5, "Dit is zech maar echt mijn ding", "2012-06-21 23:30"),
	(7, 1, 1, "Ik vond de smashing pumpkins toch beter....", "2012-06-22 23:12");

DROP TABLE IF EXISTS Challenge;
CREATE TABLE Challenge (
	challenge_hex VARCHAR(255) NOT NULL,
	created TIMESTAMP NOT NULL
);

UPDATE Showing s, 
(
	SELECT sho_id, COUNT(*) as post_count, AVG(pos_rating) as post_average FROM Post GROUP BY sho_id
) as T
SET 
	s.sho_nr_posts = T.post_count, s.sho_avg_post_rating = T.post_average
WHERE 
	s.sho_id = T.sho_id;


